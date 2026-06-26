import { Request, Response } from 'express';
import { Ride, IRide } from '../models/Ride';
import { User } from '../models/User';

export class RideController {
  async requestRide(req: Request, res: Response): Promise<void> {
    try {
      const { pickupLocation, dropoffLocation, passengerCount, paymentMethod } = req.body;
      const userId = (req as any).user?.id;

      if (!userId) {
        res.status(401).json({
          success: false,
          message: 'User not authenticated'
        });
        return;
      }

      // Create ride with proper location format
      const ride = await Ride.create({
        passengerId: userId,
        pickupLocation: {
          lat: pickupLocation.lat || pickupLocation.coordinates?.[0] || 0,
          lng: pickupLocation.lng || pickupLocation.coordinates?.[1] || 0,
          address: pickupLocation.address || '',
        },
        dropoffLocation: {
          lat: dropoffLocation.lat || dropoffLocation.coordinates?.[0] || 0,
          lng: dropoffLocation.lng || dropoffLocation.coordinates?.[1] || 0,
          address: dropoffLocation.address || '',
        },
        passengerCount: passengerCount || 1,
        paymentMethod: paymentMethod || 'cash',
        status: 'requested',
      });

      res.json({
        success: true,
        message: 'Ride requested successfully',
        data: ride
      });
    } catch (error: any) {
      console.error('Error requesting ride:', error);
      res.status(500).json({
        success: false,
        message: 'Failed to request ride',
        error: error.message
      });
    }
  }

  async getRideDetails(req: Request, res: Response): Promise<void> {
    try {
      const { rideId } = req.params;
      const ride = await Ride.findById(rideId);

      if (!ride) {
        res.status(404).json({
          success: false,
          message: 'Ride not found'
        });
        return;
      }

      res.json({
        success: true,
        data: ride
      });
    } catch (error: any) {
      console.error('Error getting ride details:', error);
      res.status(500).json({
        success: false,
        message: 'Failed to get ride details',
        error: error.message
      });
    }
  }

  async getRideHistory(req: Request, res: Response): Promise<void> {
    try {
      const userId = (req as any).user?.id;
      
      if (!userId) {
        res.status(401).json({
          success: false,
          message: 'User not authenticated'
        });
        return;
      }

      const rides = await Ride.find({ passengerId: userId });
      
      // Sort by createdAt descending (newest first)
      const sortedRides = rides.sort((a, b) => {
        const dateA = a.createdAt ? new Date(a.createdAt).getTime() : 0;
        const dateB = b.createdAt ? new Date(b.createdAt).getTime() : 0;
        return dateB - dateA;
      });

      res.json({
        success: true,
        data: sortedRides
      });
    } catch (error: any) {
      console.error('Error getting ride history:', error);
      res.status(500).json({
        success: false,
        message: 'Failed to get ride history',
        error: error.message
      });
    }
  }

  async cancelRide(req: Request, res: Response): Promise<void> {
    try {
      const { rideId } = req.params;
      const userId = (req as any).user?.id;

      const ride = await Ride.findById(rideId);
      if (!ride) {
        res.status(404).json({
          success: false,
          message: 'Ride not found'
        });
        return;
      }

      // Check if user owns this ride
      if (ride.passengerId !== userId) {
        res.status(403).json({
          success: false,
          message: 'Not authorized to cancel this ride'
        });
        return;
      }

      // Only allow cancellation if ride is in requested or matched status
      if (ride.status !== 'requested' && ride.status !== 'matched') {
        res.status(400).json({
          success: false,
          message: 'Ride cannot be cancelled at this stage'
        });
        return;
      }

      const updatedRide = await Ride.cancelRide(rideId, 'Cancelled by passenger');

      res.json({
        success: true,
        message: 'Ride cancelled successfully',
        data: updatedRide
      });
    } catch (error: any) {
      console.error('Error cancelling ride:', error);
      res.status(500).json({
        success: false,
        message: 'Failed to cancel ride',
        error: error.message
      });
    }
  }

  async rateRide(req: Request, res: Response): Promise<void> {
    try {
      const { rideId } = req.params;
      const { rating, review } = req.body;
      const userId = (req as any).user?.id;

      const ride = await Ride.findById(rideId);
      if (!ride) {
        res.status(404).json({
          success: false,
          message: 'Ride not found'
        });
        return;
      }

      // Check if user owns this ride
      if (ride.passengerId !== userId) {
        res.status(403).json({
          success: false,
          message: 'Not authorized to rate this ride'
        });
        return;
      }

      // Check if ride is completed
      if (ride.status !== 'completed') {
        res.status(400).json({
          success: false,
          message: 'Ride must be completed before rating'
        });
        return;
      }

      const updatedRide = await Ride.findByIdAndUpdate(rideId, {
        rating,
        review,
      });

      // Update driver's rating if there's a driver assigned
      if (ride.driverId) {
        const driver = await User.findById(ride.driverId);
        if (driver) {
          const currentRating = driver.rating || 0;
          const totalRides = driver.totalRides || 0;
          const newRating = ((currentRating * totalRides) + rating) / (totalRides + 1);
          
          await User.findByIdAndUpdate(ride.driverId, {
            rating: newRating,
            totalRides: totalRides + 1,
          });
        }
      }

      res.json({
        success: true,
        message: 'Ride rated successfully',
        data: updatedRide
      });
    } catch (error: any) {
      console.error('Error rating ride:', error);
      res.status(500).json({
        success: false,
        message: 'Failed to rate ride',
        error: error.message
      });
    }
  }

  async getNearbyDrivers(req: Request, res: Response): Promise<void> {
    try {
      const { lat, lng, radius = 5 } = req.query;
      
      // Find drivers who are available
      const drivers = await User.find({ 
        isDriver: true,
      });

      // Filter drivers by distance (simple implementation)
      const nearbyDrivers = drivers
        .filter(driver => {
          if (!driver.driverProfile?.location) return false;
          // Calculate distance (simplified)
          const driverLat = driver.driverProfile.location.lat || 0;
          const driverLng = driver.driverProfile.location.lng || 0;
          const distance = this.calculateDistance(
            Number(lat) || 0,
            Number(lng) || 0,
            driverLat,
            driverLng
          );
          return distance <= Number(radius);
        })
        .map(driver => ({
          id: driver.id,
          name: driver.fullName,
          rating: driver.rating || 0,
          distance: this.calculateDistance(
            Number(lat) || 0,
            Number(lng) || 0,
            driver.driverProfile?.location?.lat || 0,
            driver.driverProfile?.location?.lng || 0
          ),
          vehicleType: driver.driverProfile?.vehicleType || 'Standard',
          plateNumber: driver.driverProfile?.plateNumber || '',
        }))
        .sort((a, b) => a.distance - b.distance)
        .slice(0, 10);

      res.json({
        success: true,
        data: {
          drivers: nearbyDrivers,
          count: nearbyDrivers.length,
        }
      });
    } catch (error: any) {
      console.error('Error getting nearby drivers:', error);
      res.status(500).json({
        success: false,
        message: 'Failed to get nearby drivers',
        error: error.message
      });
    }
  }

  // Helper method to calculate distance between two points (Haversine formula)
  private calculateDistance(lat1: number, lon1: number, lat2: number, lon2: number): number {
    const R = 6371; // Earth's radius in kilometers
    const dLat = this.toRadians(lat2 - lat1);
    const dLon = this.toRadians(lon2 - lon1);
    const a = 
      Math.sin(dLat / 2) * Math.sin(dLat / 2) +
      Math.cos(this.toRadians(lat1)) * Math.cos(this.toRadians(lat2)) *
      Math.sin(dLon / 2) * Math.sin(dLon / 2);
    const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
    return R * c;
  }

  private toRadians(degrees: number): number {
    return degrees * (Math.PI / 180);
  }

  // Additional methods for driver app
  async acceptRide(req: Request, res: Response): Promise<void> {
    try {
      const { rideId } = req.params;
      const driverId = (req as any).user?.id;

      const ride = await Ride.findById(rideId);
      if (!ride) {
        res.status(404).json({
          success: false,
          message: 'Ride not found'
        });
        return;
      }

      if (ride.status !== 'requested') {
        res.status(400).json({
          success: false,
          message: 'Ride is no longer available'
        });
        return;
      }

      const updatedRide = await Ride.assignDriver(rideId, driverId);

      res.json({
        success: true,
        message: 'Ride accepted successfully',
        data: updatedRide
      });
    } catch (error: any) {
      console.error('Error accepting ride:', error);
      res.status(500).json({
        success: false,
        message: 'Failed to accept ride',
        error: error.message
      });
    }
  }

  async startRide(req: Request, res: Response): Promise<void> {
    try {
      const { rideId } = req.params;
      const driverId = (req as any).user?.id;

      const ride = await Ride.findById(rideId);
      if (!ride) {
        res.status(404).json({
          success: false,
          message: 'Ride not found'
        });
        return;
      }

      if (ride.driverId !== driverId) {
        res.status(403).json({
          success: false,
          message: 'Not authorized to start this ride'
        });
        return;
      }

      const updatedRide = await Ride.updateStatus(rideId, 'en_route');
      await Ride.findByIdAndUpdate(rideId, {
        startedAt: new Date().toISOString()
      });

      res.json({
        success: true,
        message: 'Ride started successfully',
        data: updatedRide
      });
    } catch (error: any) {
      console.error('Error starting ride:', error);
      res.status(500).json({
        success: false,
        message: 'Failed to start ride',
        error: error.message
      });
    }
  }

  async completeRide(req: Request, res: Response): Promise<void> {
    try {
      const { rideId } = req.params;
      const driverId = (req as any).user?.id;

      const ride = await Ride.findById(rideId);
      if (!ride) {
        res.status(404).json({
          success: false,
          message: 'Ride not found'
        });
        return;
      }

      if (ride.driverId !== driverId) {
        res.status(403).json({
          success: false,
          message: 'Not authorized to complete this ride'
        });
        return;
      }

      const updatedRide = await Ride.completeRide(rideId);

      res.json({
        success: true,
        message: 'Ride completed successfully',
        data: updatedRide
      });
    } catch (error: any) {
      console.error('Error completing ride:', error);
      res.status(500).json({
        success: false,
        message: 'Failed to complete ride',
        error: error.message
      });
    }
  }
}