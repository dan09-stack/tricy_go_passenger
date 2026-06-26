import { createDatabaseAdapter } from '../db-adapter';
import { JsonDBAdapter } from '../db-adapter';

export interface IOTP {
  id?: string;
  phoneNumber: string;
  code: string;
  expiresAt: string;
  isUsed: boolean;
  attempts?: number;
  createdAt?: string;
  updatedAt?: string;
}

export class OTP {
  private static getAdapter() {
    return createDatabaseAdapter();
  }

  static async findOne(query: Partial<IOTP>): Promise<IOTP | null> {
    try {
      const adapter = this.getAdapter();
      const result = await adapter.findOne<IOTP>('otps', query);
      return result;
    } catch (error) {
      console.error('Error finding OTP:', error);
      return null;
    }
  }

  static async find(query?: Partial<IOTP>): Promise<IOTP[]> {
    try {
      const adapter = this.getAdapter();
      const result = await adapter.findMany<IOTP>('otps', query || {});
      return result;
    } catch (error) {
      console.error('Error finding OTPs:', error);
      return [];
    }
  }

  static async create(data: Partial<IOTP>): Promise<IOTP> {
    try {
      const adapter = this.getAdapter();
      
      // Handle expiresAt properly - check if it's a Date object
      let expiresAtStr: string;
      if (data.expiresAt) {
        // If it's a Date object or string, convert to ISO string
        expiresAtStr = typeof data.expiresAt === 'string' 
          ? data.expiresAt 
          : new Date(data.expiresAt).toISOString();
      } else {
        // Default: 5 minutes from now
        expiresAtStr = new Date(Date.now() + 5 * 60 * 1000).toISOString();
      }
      
      const item = {
        phoneNumber: data.phoneNumber || '',
        code: data.code || '',
        expiresAt: expiresAtStr,
        isUsed: data.isUsed || false,
        attempts: data.attempts || 0,
      };
      
      console.log('📝 Creating OTP:', item);
      const result = await adapter.insertOne('otps', item);
      console.log('✅ OTP created:', result);
      return result as IOTP;
    } catch (error) {
      console.error('❌ Error creating OTP:', error);
      throw error;
    }
  }

  static async findById(id: string): Promise<IOTP | null> {
    try {
      const adapter = this.getAdapter();
      const result = await adapter.findOne<IOTP>('otps', { id });
      return result;
    } catch (error) {
      console.error('Error finding OTP by ID:', error);
      return null;
    }
  }

  static async findByIdAndUpdate(id: string, data: Partial<IOTP>): Promise<IOTP | null> {
    try {
      const adapter = this.getAdapter();
      // Use 'any' to bypass the type constraint
      const result = await (adapter as any).updateOne('otps', id, data);
      return result as IOTP | null;
    } catch (error) {
      console.error('Error updating OTP:', error);
      return null;
    }
  }

  static async deleteMany(query?: any): Promise<void> {
    try {
      const adapter = this.getAdapter();
      if (adapter instanceof JsonDBAdapter) {
        const db = (adapter as any).db;
        await db.clearCollection('otps');
      } else {
        // For MongoDB, use mongoose
        const mongoose = await import('mongoose');
        await mongoose.connection.collection('otps').deleteMany(query || {});
      }
    } catch (error) {
      console.error('Error deleting OTPs:', error);
    }
  }
}