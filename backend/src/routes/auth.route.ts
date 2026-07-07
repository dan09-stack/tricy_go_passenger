import { Router, Request, Response } from 'express';
import { body, validationResult } from 'express-validator';
import { AuthController } from '../controllers/auth.controller';
import { devOnly, requireDevFeature } from '../middleware/dev.middleware';
import { EnvConfig } from '../config/env.config';
import { OTP } from '../models/OTP';
import { rateLimit } from 'express-rate-limit';

const router = Router();
const authController = new AuthController();

// ==================== RATE LIMITERS ====================

const otpLimiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 5, // 5 OTP requests per 15 minutes
  message: 'Too many OTP requests. Please wait 15 minutes.',
});

const verifyLimiter = rateLimit({
  windowMs: 5 * 60 * 1000, // 5 minutes
  max: 3, // 3 verification attempts per 5 minutes
  message: 'Too many verification attempts. Please wait 5 minutes.',
});

// ==================== PUBLIC ROUTES ====================

// Send OTP
router.post(
  '/send-otp',
  otpLimiter,
  [
    body('phoneNumber')
      .isString()
      .withMessage('Phone number is required')
      .matches(/^[0-9]{10,15}$/)
      .withMessage('Invalid phone number format'),
  ],
  async (req: Request, res: Response): Promise<void> => {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      res.status(400).json({ errors: errors.array() });
      return;
    }
    await authController.sendOTP(req, res);
  }
);

// Verify OTP & Login/Register
router.post(
  '/verify-otp',
  verifyLimiter,
  [
    body('phoneNumber')
      .isString()
      .withMessage('Phone number is required')
      .matches(/^[0-9]{10,15}$/)
      .withMessage('Invalid phone number format'),
    body('code')
      .isString()
      .withMessage('Verification code is required')
      .isLength({ min: 6, max: 6 })
      .withMessage('Invalid verification code format'),
    body('fullName')
      .optional()
      .isString()
      .trim()
      .isLength({ min: 2 })
      .withMessage('Name must be at least 2 characters'),
    body('email')
      .optional()
      .isEmail()
      .withMessage('Invalid email format'),
  ],
  async (req: Request, res: Response): Promise<void> => {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      res.status(400).json({ errors: errors.array() });
      return;
    }
    await authController.verifyOTP(req, res);
  }
);

// Refresh Token
router.post(
  '/refresh-token',
  [
    body('refreshToken')
      .isString()
      .withMessage('Refresh token is required'),
  ],
  async (req: Request, res: Response): Promise<void> => {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      res.status(400).json({ errors: errors.array() });
      return;
    }
    await authController.refreshToken(req, res);
  }
);

// Logout
router.post('/logout', async (req: Request, res: Response): Promise<void> => {
  await authController.logout(req, res);
});

// ==================== ⭐ DEVELOPMENT-ONLY ROUTES ⭐ ====================

if (EnvConfig.isDevMode()) {
  console.log('🔧 Development routes enabled');

  // 1. Dev Login - Quick login without OTP
  router.post(
    '/dev-login',
    devOnly, // Layer 1: Environment check
    requireDevFeature('ENABLE_DEV_LOGIN'), // Layer 2: Feature flag
    authController.devLogin.bind(authController)
  );

  // 2. Get Dev OTP - Retrieve OTP without sending SMS
  router.get(
    '/dev-otp/:phoneNumber',
    devOnly,
    requireDevFeature('ENABLE_DEV_LOGIN'),
    async (req: Request, res: Response): Promise<void> => {
      try {
        const { phoneNumber } = req.params;
        
        // Find the most recent unused OTP
        const otp = await OTP.findOne({ 
          phoneNumber, 
          isUsed: false 
        });
        
        if (!otp) {
          res.status(404).json({
            success: false,
            message: 'No valid OTP found for this phone number'
          });
          return;
        }
        
        // Check if OTP is expired
        if (new Date(otp.expiresAt) < new Date()) {
          res.status(400).json({
            success: false,
            message: 'OTP has expired'
          });
          return;
        }
        
        res.json({
          success: true,
          data: {
            phoneNumber,
            otp: otp.code,
            expiresAt: otp.expiresAt,
            isUsed: otp.isUsed
          }
        });
      } catch (error: any) {
        res.status(500).json({
          success: false,
          message: 'Failed to retrieve OTP',
          error: error.message
        });
      }
    }
  );

  // 3. Get All Users (Dev only - for testing)
  router.get(
    '/dev-users',
    devOnly,
    requireDevFeature('ENABLE_DEV_LOGIN'),
    async (req: Request, res: Response): Promise<void> => {
      try {
        const { User } = await import('../models/User');
        const users = await User.find();
        res.json({
          success: true,
          data: users
        });
      } catch (error: any) {
        res.status(500).json({
          success: false,
          message: 'Failed to fetch users',
          error: error.message
        });
      }
    }
  );

  // 4. Clear All OTPs (Dev only - for testing)
  router.delete(
    '/dev-clear-otps',
    devOnly,
    requireDevFeature('ENABLE_DEV_LOGIN'),
    async (req: Request, res: Response): Promise<void> => {
      try {
        await OTP.deleteMany({});
        res.json({
          success: true,
          message: 'All OTPs cleared successfully'
        });
      } catch (error: any) {
        res.status(500).json({
          success: false,
          message: 'Failed to clear OTPs',
          error: error.message
        });
      }
    }
  );

  // 5. Reset Database (Dev only - for testing)
  router.post(
    '/dev-reset',
    devOnly,
    requireDevFeature('ENABLE_DEV_LOGIN'),
    async (req: Request, res: Response): Promise<void> => {
      try {
        const { User } = await import('../models/User');
        const { Ride } = await import('../models/Ride');
        
        await User.deleteMany({});
        await Ride.deleteMany({});
        await OTP.deleteMany({});
        
        res.json({
          success: true,
          message: 'Database reset successfully'
        });
      } catch (error: any) {
        res.status(500).json({
          success: false,
          message: 'Failed to reset database',
          error: error.message
        });
      }
    }
  );

  console.log('✅ Dev routes registered:');
  console.log('  POST /api/auth/dev-login');
  console.log('  GET  /api/auth/dev-otp/:phoneNumber');
  console.log('  GET  /api/auth/dev-users');
  console.log('  DELETE /api/auth/dev-clear-otps');
  console.log('  POST /api/auth/dev-reset');
}

export { router as authRouter };