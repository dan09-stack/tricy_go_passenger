import twilio from 'twilio';
import dotenv from 'dotenv';

dotenv.config();

export class TwilioService {
  private client: twilio.Twilio;
  private phoneNumber: string;

  constructor() {
    const accountSid = process.env.TWILIO_ACCOUNT_SID;
    const authToken = process.env.TWILIO_AUTH_TOKEN;
    this.phoneNumber = process.env.TWILIO_PHONE_NUMBER || '';

    if (!accountSid || !authToken) {
      console.warn('⚠️ Twilio credentials not configured. SMS will not work.');
    }

    this.client = twilio(accountSid!, authToken!);
  }

  async sendSMS(to: string, message: string): Promise<any> {
    try {
      const response = await this.client.messages.create({
        body: message,
        to: to.startsWith('+') ? to : `+63${to}`,
        from: this.phoneNumber,
      });
      console.log(`📱 SMS sent to ${to}: ${response.sid}`);
      return response;
    } catch (error) {
      console.error('Failed to send SMS:', error);
      throw error;
    }
  }

  async sendOTP(phoneNumber: string, code: string): Promise<void> {
    const message = `🔐 Your TricyGo verification code is: ${code}\n\nThis code will expire in 5 minutes.`;
    await this.sendSMS(phoneNumber, message);
  }

  async sendRideConfirmation(phoneNumber: string, rideDetails: any): Promise<void> {
    const message = `🚗 TricyGo Ride Confirmed!\n\n` +
      `Driver: ${rideDetails.driverName}\n` +
      `Vehicle: ${rideDetails.vehicle}\n` +
      `ETA: ${rideDetails.eta} minutes\n` +
      `Pickup: ${rideDetails.pickupAddress}\n\n` +
      `Track your ride in the app.`;
    await this.sendSMS(phoneNumber, message);
  }

  async sendRideCompleted(phoneNumber: string, rideDetails: any): Promise<void> {
    const message = `✅ TricyGo Ride Completed!\n\n` +
      `Fare: ₱${rideDetails.fare.toFixed(2)}\n` +
      `Distance: ${rideDetails.distance} km\n` +
      `Duration: ${rideDetails.duration} minutes\n\n` +
      `Rate your driver in the app.`;
    await this.sendSMS(phoneNumber, message);
  }
}