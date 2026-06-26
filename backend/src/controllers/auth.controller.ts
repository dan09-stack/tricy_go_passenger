// src/controllers/auth.controller.ts
import { Request, Response } from 'express';
import jwt from 'jsonwebtoken';
import { User } from '../models/User';
import { OTP } from '../models/OTP';
import { TwilioService } from '../services/twilio.service';
import { EnvConfig } from '../config/env.config';

export class AuthController {
  private twilioService: TwilioService;

  constructor() {
    this.twilioService = new TwilioService();
  }

  // Helper method to generate JWT with proper typing
  private generateToken(user: any): string {
    const secret = process.env.JWT_SECRET || 'secret';
    const expiresIn = process.env.JWT_EXPIRES_IN || '7d';
    
    const payload = { 
      userId: user.id, 
      phoneNumber: user.phoneNumber 
    };
    
    // Use type assertion to help TypeScript
    return jwt.sign(
      payload, 
      secret, 
      { expiresIn: expiresIn } as jwt.SignOptions
    );
  }

  async sendOTP(req: Request, res: Response): Promise<void> {
    try {
      const { phoneNumber } = req.body;
      
      // Validate phone number format
      if (!phoneNumber || phoneNumber.length < 10) {
        res.status(400).json({
          success: false,
          message: 'Invalid phone number'
        });
        return;
      }

      // Generate OTP
      const code = EnvConfig.isDevMode() && EnvConfig.getDevOTP()
        ? EnvConfig.getDevOTP()!
        : Math.floor(100000 + Math.random() * 900000).toString();
      
      // Save OTP to database
      await OTP.create({
        phoneNumber,
        code,
        expiresAt: new Date(Date.now() + 5 * 60 * 1000).toISOString(),
        isUsed: false
      });
      
      // Send SMS (only in production or if explicitly configured)
      if (EnvConfig.isProduction() || process.env.FORCE_SMS === 'true') {
        await this.twilioService.sendOTP(phoneNumber, code);
      } else {
        console.log(`📱 [DEV] OTP for ${phoneNumber}: ${code}`);
      }
      
      res.json({
        success: true,
        message: EnvConfig.isProduction() 
          ? 'OTP sent successfully' 
          : 'OTP sent (development mode)',
        data: { 
          phoneNumber, 
          expiresIn: 300,
          // Only include OTP in development with explicit flag
          ...(EnvConfig.isDevMode() && process.env.SHOW_DEV_OTP === 'true' && { devOTP: code })
        },
      });
    } catch (error: any) {
      console.error('Error sending OTP:', error);
      res.status(500).json({
        success: false,
        message: 'Failed to send OTP',
        error: EnvConfig.isDevMode() ? error.message : undefined,
      });
    }
  }

  async verifyOTP(req: Request, res: Response): Promise<void> {
    try {
      const { phoneNumber, code, fullName, email } = req.body;

      // Production safety check - never auto-verify in production
      if (EnvConfig.isProduction() && EnvConfig.shouldBypassOTP()) {
        console.warn('⚠️ OTP bypass is disabled in production');
        res.status(403).json({
          success: false,
          message: 'OTP bypass not allowed in production'
        });
        return;
      }

      let user: any = null;
      let verificationMethod = 'otp';

      // DEVELOPMENT BYPASS - Only in non-production with explicit flag
      if (EnvConfig.shouldBypassOTP()) {
        console.log('🔓 [DEV] OTP bypass enabled');
        
        // Log the bypass attempt for security auditing
        console.log(`⚠️ [DEV] OTP bypass used for phone: ${phoneNumber}`);
        
        // Find or create user (still need valid user)
        user = await User.findOne({ phoneNumber });
        
        if (!user) {
          user = await User.create({
            phoneNumber,
            fullName: fullName || 'Dev User',
            email,
            isVerified: true,
          });
        }
        
        verificationMethod = 'bypass';
      } else {
        // NORMAL OTP VERIFICATION
        const otpRecord = await OTP.findOne({
          phoneNumber,
          code,
          isUsed: false,
        });

        // Check if OTP exists and is not expired
        if (!otpRecord || new Date(otpRecord.expiresAt) < new Date()) {
          res.status(400).json({
            success: false,
            message: 'Invalid or expired OTP',
          });
          return;
        }
        
        // Mark OTP as used
        await OTP.findByIdAndUpdate(otpRecord.id!, { isUsed: true });
        
        // Find or create user
        user = await User.findOne({ phoneNumber });
        
        if (!user) {
          user = await User.create({
            phoneNumber,
            fullName: fullName || 'User',
            email,
            isVerified: true,
          });
        }
      }

      // Generate JWT using the helper method
      const token = this.generateToken(user);
      
      res.json({
        success: true,
        message: verificationMethod === 'bypass' 
          ? 'Authentication successful (development bypass)' 
          : 'Authentication successful',
        data: {
          token,
          user: {
            id: user.id,
            phoneNumber: user.phoneNumber,
            fullName: user.fullName,
            email: user.email,
            isVerified: user.isVerified,
          },
          // Only include this in development
          ...(EnvConfig.isDevMode() && { 
            _dev: { verificationMethod }
          })
        },
      });
    } catch (error: any) {
      console.error('Error verifying OTP:', error);
      res.status(500).json({
        success: false,
        message: 'OTP verification failed',
        ...(EnvConfig.isDevMode() && { error: error.message }),
      });
    }
  }

  async refreshToken(req: Request, res: Response): Promise<void> {
    try {
      const { refreshToken } = req.body;
      
      const secret = process.env.JWT_SECRET || 'secret';
      const decoded = jwt.verify(refreshToken, secret) as any;
      const user = await User.findById(decoded.userId);
      
      if (!user) {
        res.status(404).json({
          success: false,
          message: 'User not found',
        });
        return;
      }
      
      // Generate JWT using the helper method
      const token = this.generateToken(user);
      
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
    res.json({
      success: true,
      message: 'Logged out successfully',
    });
  }

  // Development-only endpoint with multiple safety layers
  async devLogin(req: Request, res: Response): Promise<void> {
    // Layer 1: Environment check
    if (!EnvConfig.isDevMode()) {
      res.status(403).json({
        success: false,
        message: 'Dev login only available in development'
      });
      return;
    }

    // Layer 2: Feature flag check
    if (process.env.ENABLE_DEV_LOGIN !== 'true') {
      res.status(403).json({
        success: false,
        message: 'Dev login is disabled. Set ENABLE_DEV_LOGIN=true to enable'
      });
      return;
    }

    // Layer 3: IP restriction (optional)
    const clientIp = req.ip || req.connection.remoteAddress;
    const allowedIps = (process.env.ALLOWED_DEV_IPS || '').split(',');
    if (allowedIps.length > 0 && !allowedIps.includes(clientIp || '')) {
      console.warn(`⚠️ Dev login attempt from unauthorized IP: ${clientIp}`);
      res.status(403).json({
        success: false,
        message: 'Unauthorized IP for dev login'
      });
      return;
    }

    try {
      const { phoneNumber = '09123456789', fullName = 'Dev User' } = req.body;
      
      // Log all dev login attempts for auditing
      console.log(`🔓 [DEV LOGIN] Phone: ${phoneNumber}, IP: ${clientIp}`);
      
      // Find or create user
      let user = await User.findOne({ phoneNumber });
      
      if (!user) {
        user = await User.create({
          phoneNumber,
          fullName,
          isVerified: true,
        });
      }
      
      // Generate JWT using the helper method
      const token = this.generateToken(user);
      
      res.json({
        success: true,
        message: 'Development login successful',
        data: {
          token,
          user: {
            id: user.id,
            phoneNumber: user.phoneNumber,
            fullName: user.fullName,
            email: user.email,
            isVerified: user.isVerified,
          },
          _dev: {
            expiresIn: process.env.JWT_EXPIRES_IN || '7d',
            loginMethod: 'dev-login'
          }
        },
      });
    } catch (error: any) {
      console.error('Dev login error:', error);
      res.status(500).json({
        success: false,
        message: 'Dev login failed',
        error: error.message,
      });
    }
  }
}