// src/services/twilio.service.ts
import twilio from 'twilio';
import dotenv from 'dotenv';

dotenv.config();

export class TwilioService {
  private client: any;
  private isConfigured: boolean;

  constructor() {
    const accountSid = process.env.TWILIO_ACCOUNT_SID;
    const authToken = process.env.TWILIO_AUTH_TOKEN;
    
    this.isConfigured = !!(accountSid && authToken);
    
    if (this.isConfigured) {
      this.client = twilio(accountSid, authToken);
      console.log('✅ Twilio configured successfully');
    } else {
      console.warn('⚠️ Twilio credentials not configured. SMS will not work.');
      // Create a mock client for development
      this.client = {
        messages: {
          create: async (params: any) => {
            console.log('📱 [MOCK] SMS would be sent:', {
              to: params.to,
              body: params.body,
              from: process.env.TWILIO_PHONE_NUMBER || '+1234567890'
            });
            return { sid: 'mock_sid_' + Date.now() };
          }
        }
      };
    }
  }

  async sendOTP(phoneNumber: string, code: string): Promise<void> {
    try {
      if (!this.isConfigured) {
        console.log(`📱 [MOCK] OTP ${code} sent to ${phoneNumber}`);
        return;
      }

      const message = await this.client.messages.create({
        body: `Your TricyGo verification code is: ${code}. This code will expire in 5 minutes.`,
        to: phoneNumber,
        from: process.env.TWILIO_PHONE_NUMBER,
      });
      
      console.log(`✅ OTP sent to ${phoneNumber}, SID: ${message.sid}`);
    } catch (error: any) {
      console.error('❌ Failed to send OTP:', error.message);
      throw new Error('Failed to send OTP. Please try again.');
    }
  }

  getConfiguredStatus(): boolean {
    return this.isConfigured;
  }
}