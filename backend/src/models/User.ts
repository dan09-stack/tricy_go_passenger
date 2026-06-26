import { createDatabaseAdapter } from '../db-adapter';
import { JsonDBAdapter } from '../db-adapter';

export interface IUser {
  id?: string;
  phoneNumber: string;
  fullName: string;
  email?: string;
  isVerified: boolean;
  avatar?: string;
  rating?: number;
  totalRides?: number;
  isDriver?: boolean;
  driverProfile?: {
    vehicleType: string;
    plateNumber: string;
    isAvailable: boolean;
    location?: {
      lat: number;
      lng: number;
    };
  };
  preferences?: {
    notifications: boolean;
    emailUpdates: boolean;
    smsUpdates: boolean;
  };
  createdAt?: string;
  updatedAt?: string;
}

export class User {
  private static getAdapter() {
    return createDatabaseAdapter();
  }

  static async findOne(query: Partial<IUser>): Promise<IUser | null> {
    try {
      const adapter = this.getAdapter();
      const result = await adapter.findOne('users', query);
      return result as IUser | null;
    } catch (error) {
      console.error('Error finding user:', error);
      return null;
    }
  }

  static async findById(id: string): Promise<IUser | null> {
    try {
      const adapter = this.getAdapter();
      const result = await adapter.findOne('users', { id });
      return result as IUser | null;
    } catch (error) {
      console.error('Error finding user by ID:', error);
      return null;
    }
  }

  static async find(query?: Partial<IUser>): Promise<IUser[]> {
    try {
      const adapter = this.getAdapter();
      const result = await adapter.findMany('users', query || {});
      return result as IUser[];
    } catch (error) {
      console.error('Error finding users:', error);
      return [];
    }
  }

  static async create(data: Partial<IUser>): Promise<IUser> {
    try {
      const adapter = this.getAdapter();
      
      const item = {
        phoneNumber: data.phoneNumber || '',
        fullName: data.fullName || 'User',
        email: data.email,
        isVerified: data.isVerified || false,
        avatar: data.avatar,
        rating: data.rating || 0,
        totalRides: data.totalRides || 0,
        isDriver: data.isDriver || false,
        driverProfile: data.driverProfile || {
          vehicleType: '',
          plateNumber: '',
          isAvailable: false,
          location: { lat: 0, lng: 0 },
        },
        preferences: data.preferences || {
          notifications: true,
          emailUpdates: true,
          smsUpdates: true,
        },
      };
      
      console.log('📝 Creating user:', item);
      const result = await adapter.insertOne('users', item);
      console.log('✅ User created:', result);
      return result as IUser;
    } catch (error) {
      console.error('❌ Error creating user:', error);
      throw error;
    }
  }

  static async findByIdAndUpdate(id: string, data: Partial<IUser>): Promise<IUser | null> {
    try {
      const adapter = this.getAdapter();
      const result = await (adapter as any).updateOne('users', id, data);
      return result as IUser | null;
    } catch (error) {
      console.error('Error updating user:', error);
      return null;
    }
  }

  static async findByIdAndDelete(id: string): Promise<boolean> {
    try {
      const adapter = this.getAdapter();
      const result = await adapter.deleteOne('users', id);
      return result;
    } catch (error) {
      console.error('Error deleting user:', error);
      return false;
    }
  }

  static async findOneAndUpdate(query: Partial<IUser>, data: Partial<IUser>): Promise<IUser | null> {
    try {
      const user = await this.findOne(query);
      if (!user || !user.id) return null;
      return this.findByIdAndUpdate(user.id, data);
    } catch (error) {
      console.error('Error finding and updating user:', error);
      return null;
    }
  }

  static async deleteMany(query?: any): Promise<void> {
    try {
      const adapter = this.getAdapter();
      if (adapter instanceof JsonDBAdapter) {
        const db = (adapter as any).db;
        await db.clearCollection('users');
      } else {
        const mongoose = await import('mongoose');
        await mongoose.connection.collection('users').deleteMany(query || {});
      }
    } catch (error) {
      console.error('Error deleting users:', error);
    }
  }

  // Helper method to update driver location
  static async updateDriverLocation(id: string, lat: number, lng: number): Promise<IUser | null> {
    try {
      const user = await this.findById(id);
      if (!user) return null;
      
      // Preserve existing driver profile or create a new one
      const existingProfile = user.driverProfile || {
        vehicleType: '',
        plateNumber: '',
        isAvailable: false,
      };
      
      // Update only the location, keep other fields
      const updatedProfile = {
        ...existingProfile,
        location: { lat, lng },
      };
      
      return this.findByIdAndUpdate(id, {
        driverProfile: updatedProfile,
      });
    } catch (error) {
      console.error('Error updating driver location:', error);
      return null;
    }
  }

  // Helper method to update driver availability
  static async updateDriverAvailability(id: string, isAvailable: boolean): Promise<IUser | null> {
    try {
      const user = await this.findById(id);
      if (!user) return null;
      
      const existingProfile = user.driverProfile || {
        vehicleType: '',
        plateNumber: '',
        isAvailable: false,
        location: { lat: 0, lng: 0 },
      };
      
      const updatedProfile = {
        ...existingProfile,
        isAvailable,
      };
      
      return this.findByIdAndUpdate(id, {
        driverProfile: updatedProfile,
      });
    } catch (error) {
      console.error('Error updating driver availability:', error);
      return null;
    }
  }

  // Helper method to get available drivers
  static async getAvailableDrivers(): Promise<IUser[]> {
    try {
      const users = await this.find({ isDriver: true });
      return users.filter(user => 
        user.driverProfile?.isAvailable === true
      );
    } catch (error) {
      console.error('Error getting available drivers:', error);
      return [];
    }
  }

  // Helper method to get drivers near a location
  static async getNearbyDrivers(lat: number, lng: number, radius: number = 5): Promise<IUser[]> {
    try {
      const drivers = await this.getAvailableDrivers();
      
      // Filter drivers by distance
      const nearby = drivers.filter(driver => {
        const driverLat = driver.driverProfile?.location?.lat || 0;
        const driverLng = driver.driverProfile?.location?.lng || 0;
        const distance = calculateDistance(lat, lng, driverLat, driverLng);
        return distance <= radius;
      });
      
      // Sort by distance
      nearby.sort((a, b) => {
        const distA = calculateDistance(
          lat, lng,
          a.driverProfile?.location?.lat || 0,
          a.driverProfile?.location?.lng || 0
        );
        const distB = calculateDistance(
          lat, lng,
          b.driverProfile?.location?.lat || 0,
          b.driverProfile?.location?.lng || 0
        );
        return distA - distB;
      });
      
      return nearby;
    } catch (error) {
      console.error('Error getting nearby drivers:', error);
      return [];
    }
  }
}

// Helper function for distance calculation
function calculateDistance(lat1: number, lon1: number, lat2: number, lon2: number): number {
  const R = 6371; // Earth's radius in kilometers
  const dLat = toRadians(lat2 - lat1);
  const dLon = toRadians(lon2 - lon1);
  const a = 
    Math.sin(dLat / 2) * Math.sin(dLat / 2) +
    Math.cos(toRadians(lat1)) * Math.cos(toRadians(lat2)) *
    Math.sin(dLon / 2) * Math.sin(dLon / 2);
  const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
  return R * c;
}

function toRadians(degrees: number): number {
  return degrees * (Math.PI / 180);
}