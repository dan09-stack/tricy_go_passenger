import express, { Request, Response } from 'express';
import { body, validationResult, ValidationChain } from 'express-validator';
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

// Wrapper function to handle validation and types
const validate = (validations: ValidationChain[]) => {
  return async (req: Request, res: Response, next: any) => {
    await Promise.all(validations.map(validation => validation.run(req)));
    
    const errors = validationResult(req);
    if (errors.isEmpty()) {
      return next();
    }
    
    res.status(400).json({ errors: errors.array() });
  };
};

// Wrapper for controller methods
const asyncHandler = (fn: (req: Request, res: Response) => Promise<void>) => {
  return async (req: Request, res: Response): Promise<void> => {
    try {
      await fn(req, res);
    } catch (error: any) {
      res.status(500).json({
        success: false,
        message: 'Internal server error',
        error: error.message
      });
    }
  };
};

// Send OTP
router.post(
  '/send-otp',
  otpLimiter,
  validate([
    body('phoneNumber')
      .isString()
      .withMessage('Phone number is required')
      .matches(/^[0-9]{10,15}$/)
      .withMessage('Invalid phone number format'),
  ]),
  asyncHandler(authController.sendOTP.bind(authController))
);

// Verify OTP and login/register
router.post(
  '/verify-otp',
  verifyLimiter,
  validate([
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
  ]),
  asyncHandler(authController.verifyOTP.bind(authController))
);

// Refresh token
router.post(
  '/refresh-token',
  validate([
    body('refreshToken')
      .isString()
      .withMessage('Refresh token is required'),
  ]),
  asyncHandler(authController.refreshToken.bind(authController))
);

// Logout
router.post('/logout', asyncHandler(authController.logout.bind(authController)));

export { router as authRouter };