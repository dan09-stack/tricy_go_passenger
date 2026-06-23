import { Request, Response } from 'express';
import jwt from 'jsonwebtoken';
import { User } from '../models/User';
import { OTP } from '../models/OTP';
import { TwilioService } from '../services/twilio.service';

export class AuthController {
  private twilioService: TwilioService;

  constructor() {
    this.twilioService = new TwilioService();
  }

  async sendOTP(req: Request, res: Response): Promise<void> {
    try {
      const { phoneNumber } = req.body;
      
      // Generate 6-digit OTP
      const code = Math.floor(100000 + Math.random() * 900000).toString();
      
      // Save OTP to database
      await OTP.create({
        phoneNumber,
        code,
        expiresAt: new Date(Date.now() + 5 * 60 * 1000), // 5 minutes
      });
      
      // Send SMS
      await this.twilioService.sendOTP(phoneNumber, code);
      
      res.json({
        success: true,
        message: 'OTP sent successfully',
        data: { phoneNumber, expiresIn: 300 },
      });
    } catch (error: any) {
      res.status(500).json({
        success: false,
        message: 'Failed to send OTP',
        error: error.message,
      });
    }
  }

  async verifyOTP(req: Request, res: Response): Promise<void> {
    try {
      const { phoneNumber, code, fullName, email } = req.body;
      
      // Find and verify OTP
      const otpRecord = await OTP.findOne({
        phoneNumber,
        code,
        isUsed: false,
        expiresAt: { $gt: new Date() },
      });
      
      if (!otpRecord) {
        res.status(400).json({
          success: false,
          message: 'Invalid or expired OTP',
        });
        return;
      }
      
      // Mark OTP as used
      await OTP.findByIdAndUpdate(otpRecord._id, { isUsed: true });
      
      // Find or create user
      let user = await User.findOne({ phoneNumber });
      
      if (!user) {
        user = await User.create({
          phoneNumber,
          fullName: fullName || 'User',
          email,
          isVerified: true,
        });
      }
      
      // Generate JWT
      const token = jwt.sign(
        { userId: user._id, phoneNumber: user.phoneNumber },
        process.env.JWT_SECRET || 'secret',
        { expiresIn: process.env.JWT_EXPIRES_IN || '7d' }
      );
      
      res.json({
        success: true,
        message: 'Authentication successful',
        data: {
          token,
          user: {
            id: user._id,
            phoneNumber: user.phoneNumber,
            fullName: user.fullName,
            email: user.email,
            isVerified: user.isVerified,
          },
        },
      });
    } catch (error: any) {
      res.status(500).json({
        success: false,
        message: 'OTP verification failed',
        error: error.message,
      });
    }
  }

  async refreshToken(req: Request, res: Response): Promise<void> {
    try {
      const { refreshToken } = req.body;
      
      // Implement refresh token logic
      // For now, we'll just generate a new token
      const decoded = jwt.verify(refreshToken, process.env.JWT_SECRET || 'secret') as any;
      const user = await User.findById(decoded.userId);
      
      if (!user) {
        res.status(404).json({
          success: false,
          message: 'User not found',
        });
        return;
      }
      
      const token = jwt.sign(
        { userId: user._id, phoneNumber: user.phoneNumber },
        process.env.JWT_SECRET || 'secret',
        { expiresIn: process.env.JWT_EXPIRES_IN || '7d' }
      );
      
      res.json({
        success: true,
        data: { token },
      });
    } catch (error: any) {
      res.status(401).json({
        success: false,
        message: 'Invalid refresh token',
      });
    }
  }

  async logout(req: Request, res: Response): Promise<void> {
    // In a stateless JWT system, logout is handled client-side
    // This endpoint can be used for token blacklisting if needed
    res.json({
      success: true,
      message: 'Logged out successfully',
    });
  }
}