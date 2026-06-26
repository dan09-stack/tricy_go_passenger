// src/routes/auth.route.ts
import { Router } from 'express';
import { AuthController } from '../controllers/auth.controller';
import { devOnly, requireDevFeature } from '../middleware/dev.middleware';
import { EnvConfig } from '../config/env.config';
import { OTP } from '../models/OTP';

const router = Router();
const authController = new AuthController();

// Normal routes (always available)
router.post('/send-otp', authController.sendOTP.bind(authController));
router.post('/verify-otp', authController.verifyOTP.bind(authController));
router.post('/refresh-token', authController.refreshToken.bind(authController));
router.post('/logout', authController.logout.bind(authController));

// Development-only routes - Protected by multiple layers
if (EnvConfig.isDevMode()) {
  router.post(
    '/dev-login',
    devOnly, // Layer 1: Environment check
    requireDevFeature('ENABLE_DEV_LOGIN'), // Layer 2: Feature flag
    authController.devLogin.bind(authController)
  );
  
  // Optional: Dev route to get OTP without sending SMS
  router.get(
    '/dev-otp/:phoneNumber',
    devOnly,
    requireDevFeature('ENABLE_DEV_LOGIN'),
    async (req, res) => {
      const { phoneNumber } = req.params;
      const otp = await OTP.findOne({ 
        phoneNumber, 
        isUsed: false 
      });
      res.json({
        success: true,
        data: { otp: otp?.code }
      });
    }
  );
}

export { router as authRouter };