import express from 'express';
import { body, validationResult } from 'express-validator';
import { AuthController } from '../controllers/auth.controller';
import { rateLimit } from 'express-rate-limit';

const router = express.Router();
const authController = new AuthController();

// Rate limiter for OTP requests
const otpLimiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 5, // 5 OTP requests per 15 minutes
  message: 'Too many OTP requests. Please wait 15 minutes.',
});

// Rate limiter for verification
const verifyLimiter = rateLimit({
  windowMs: 5 * 60 * 1000, // 5 minutes
  max: 3, // 3 verification attempts per 5 minutes
  message: 'Too many verification attempts. Please wait 5 minutes.',
});

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
  async (req, res) => {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({ errors: errors.array() });
    }
    await authController.sendOTP(req, res);
  }
);

// Verify OTP and login/register
router.post(
  '/verify-otp',
  verifyLimiter,
  [
    body('phoneNumber')
      .isString()
      .withMessage('Phone number is required'),
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
  async (req, res) => {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({ errors: errors.array() });
    }
    await authController.verifyOTP(req, res);
  }
);

// Refresh token
router.post(
  '/refresh-token',
  [
    body('refreshToken')
      .isString()
      .withMessage('Refresh token is required'),
  ],
  async (req, res) => {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({ errors: errors.array() });
    }
    await authController.refreshToken(req, res);
  }
);

// Logout
router.post('/logout', async (req, res) => {
  await authController.logout(req, res);
});

export { router as authRouter };