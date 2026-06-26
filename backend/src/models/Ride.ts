import { createDatabaseAdapter } from '../db-adapter';
import { JsonDBAdapter } from '../db-adapter';

export interface IRide {
  id?: string;
  passengerId: string;
  driverId?: string;
  status: 'requested' | 'matched' | 'en_route' | 'completed' | 'cancelled';
  pickupLocation: {
    lat: number;
    lng: number;
    address: string;
  };
  dropoffLocation: {
    lat: number;
    lng: number;
    address: string;
  };
  passengerCount: number;
  fare?: number;
  distance?: number;
  duration?: number;
  paymentMethod: 'cash' | 'card' | 'wallet';
  paymentStatus?: 'pending' | 'paid' | 'failed';
  rating?: number;
  review?: string;
  driverLocation?: {
    lat: number;
    lng: number;
  };
  startedAt?: string;
  completedAt?: string;
  cancelledAt?: string;
  cancellationReason?: string;
  createdAt?: string;
  updatedAt?: string;
}

export class Ride {
  private static getAdapter() {
    return createDatabaseAdapter();
  }

  static async findOne(query: Partial<IRide>): Promise<IRide | null> {
    try {
      const adapter = this.getAdapter();
      const result = await adapter.findOne('rides', query);
      return result as IRide | null;
    } catch (error) {
      console.error('Error finding ride:', error);
      return null;
    }
  }

  static async findById(id: string): Promise<IRide | null> {
    try {
      const adapter = this.getAdapter();
      const result = await adapter.findOne('rides', { id });
      return result as IRide | null;
    } catch (error) {
      console.error('Error finding ride by ID:', error);
      return null;
    }
  }

  static async find(query?: Partial<IRide>): Promise<IRide[]> {
    try {
      const adapter = this.getAdapter();
      const result = await adapter.findMany('rides', query || {});
      return result as IRide[];
    } catch (error) {
      console.error('Error finding rides:', error);
      return [];
    }
  }

  static async create(data: Partial<IRide>): Promise<IRide> {
    try {
      const adapter = this.getAdapter();
      
      const item = {
        passengerId: data.passengerId || '',
        driverId: data.driverId,
        status: data.status || 'requested',
        pickupLocation: data.pickupLocation || { lat: 0, lng: 0, address: '' },
        dropoffLocation: data.dropoffLocation || { lat: 0, lng: 0, address: '' },
        passengerCount: data.passengerCount || 1,
        fare: data.fare || 0,
        distance: data.distance || 0,
        duration: data.duration || 0,
        paymentMethod: data.paymentMethod || 'cash',
        paymentStatus: data.paymentStatus || 'pending',
        rating: data.rating,
        review: data.review,
        driverLocation: data.driverLocation,
        startedAt: data.startedAt,
        completedAt: data.completedAt,
        cancelledAt: data.cancelledAt,
        cancellationReason: data.cancellationReason,
      };
      
      console.log('📝 Creating ride:', item);
      const result = await adapter.insertOne('rides', item);
      console.log('✅ Ride created:', result);
      return result as IRide;
    } catch (error) {
      console.error('❌ Error creating ride:', error);
      throw error;
    }
  }

  static async findByIdAndUpdate(id: string, data: Partial<IRide>): Promise<IRide | null> {
    try {
      const adapter = this.getAdapter();
      const result = await (adapter as any).updateOne('rides', id, data);
      return result as IRide | null;
    } catch (error) {
      console.error('Error updating ride:', error);
      return null;
    }
  }

  static async findByIdAndDelete(id: string): Promise<boolean> {
    try {
      const adapter = this.getAdapter();
      const result = await adapter.deleteOne('rides', id);
      return result;
    } catch (error) {
      console.error('Error deleting ride:', error);
      return false;
    }
  }

  static async deleteMany(query?: any): Promise<void> {
    try {
      const adapter = this.getAdapter();
      if (adapter instanceof JsonDBAdapter) {
        const db = (adapter as any).db;
        await db.clearCollection('rides');
      } else {
        const mongoose = await import('mongoose');
        await mongoose.connection.collection('rides').deleteMany(query || {});
      }
    } catch (error) {
      console.error('Error deleting rides:', error);
    }
  }

  // Additional helper methods used by the controller
  
  static async cancelRide(id: string, reason?: string): Promise<IRide | null> {
    try {
      const ride = await this.findById(id);
      if (!ride) return null;
      
      return this.findByIdAndUpdate(id, {
        status: 'cancelled',
        cancelledAt: new Date().toISOString(),
        cancellationReason: reason || 'Cancelled',
      });
    } catch (error) {
      console.error('Error cancelling ride:', error);
      return null;
    }
  }

  static async assignDriver(id: string, driverId: string): Promise<IRide | null> {
    try {
      const ride = await this.findById(id);
      if (!ride) return null;
      
      // Check if ride can be assigned
      if (ride.status !== 'requested') {
        console.error('Ride cannot be assigned, status is:', ride.status);
        return null;
      }
      
      return this.findByIdAndUpdate(id, {
        driverId: driverId,
        status: 'matched',
      });
    } catch (error) {
      console.error('Error assigning driver:', error);
      return null;
    }
  }

  static async updateStatus(id: string, status: IRide['status']): Promise<IRide | null> {
    try {
      const ride = await this.findById(id);
      if (!ride) return null;
      
      return this.findByIdAndUpdate(id, { status });
    } catch (error) {
      console.error('Error updating ride status:', error);
      return null;
    }
  }

  static async completeRide(id: string): Promise<IRide | null> {
    try {
      const ride = await this.findById(id);
      if (!ride) return null;
      
      return this.findByIdAndUpdate(id, {
        status: 'completed',
        completedAt: new Date().toISOString(),
      });
    } catch (error) {
      console.error('Error completing ride:', error);
      return null;
    }
  }

  static async findByPassengerId(passengerId: string): Promise<IRide[]> {
    return this.find({ passengerId });
  }

  static async findByDriverId(driverId: string): Promise<IRide[]> {
    return this.find({ driverId });
  }

  static async findActiveRides(): Promise<IRide[]> {
    return this.find({ status: 'requested' });
  }

  static async findByStatus(status: IRide['status']): Promise<IRide[]> {
    return this.find({ status });
  }
}