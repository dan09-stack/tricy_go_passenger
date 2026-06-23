import { Request, Response } from'express';
import { Ride } from'../models/Ride';
import { User } from'../models/User';
import { AuthRequest } from'../middleware/auth.middleware';

export class RideController {
  async requestRide(req: AuthRequest, res: Response): Promise<void> {
    try {
      const { pickupLocation, dropoffLocation, passengerCount, paymentMethod } = req.body;
      const passengerId = req.user._id;
      
      // Calculate fare (simplified)
      const fare = 45 + passengerCount * 10;
      
      // Create ride request
      const ride = await Ride.create({
        passenger: passengerId,
        pickupLocation: {
          coordinates: [pickupLocation.lng, pickupLocation.lat],
          address: pickupLocation.address,
        },
        dropoffLocation: {
          coordinates: [dropoffLocation.lng, dropoffLocation.lat],
          address: dropoffLocation.address,
        },
        passengerCount,
        fare,
        paymentMethod,
        status:'requested',
        distance: 3.5, // Mock distance
        duration: 10, // Mock duration
      });
      
      // Find nearby drivers (simplified)
      // In real implementation, this would use geospatial queries
      const nearbyDrivers = await User.find({
        isDriver: true,
       'driverProfile.isAvailable': true,
      }).limit(5);
      
      // Here you would implement matching logic
      // For now, we'll just return the ride request
      
      res.status(201).json({
        success: true,
        message:'Ride requested successfully',
        data: ride,
        availableDrivers: nearbyDrivers.length,
      });
    } catch (error: any) {
      res.status(500).json({
        success: false,
        message:'Failed to request ride',
        error: error.message,
      });
    }
  }

  async getRideDetails(req: Request, res: Response): Promise<void> {
    try {
      const { rideId } = req.params;
      
      const ride = await Ride.findById(rideId)
        .populate('passenger','fullName phoneNumber')
        .populate('driver','fullName phoneNumber rating driverProfile');
      
      if (!ride) {
        res.status(404).json({
          success: false,
          message:'Ride not found',
        });
        return;
      }
      
      res.json({
        success: true,
        data: ride,
      });
    } catch (error: any) {
      res.status(500).json({
        success: false,
        message:'Failed to get ride details',
        error: error.message,
      });
    }
  }

  async getRideHistory(req: AuthRequest, res: Response): Promise<void> {
    try {
      const rides = await Ride.find({ passenger: req.user._id })
        .sort({ createdAt: -1 })
        .populate('driver','fullName rating')
        .limit(50);
      
      res.json({
        success: true,
        data: rides,
        count: rides.length,
      });
    } catch (error: any) {
      res.status(500).json({
        success: false,
        message:'Failed to get ride history',
        error: error.message,
      });
    }
  }

  async cancelRide(req: AuthRequest, res: Response): Promise<void> {
    try {
      const { rideId } = req.params;
      const { reason } = req.body;
      
      const ride = await Ride.findById(rideId);
      
      if (!ride) {
        res.status(404).json({
          success: false,
          message:'Ride not found',
        });
        return;
      }
      
      if (ride.passenger.toString() !== req.user._id.toString()) {
        res.status(403).json({
          success: false,
          message:'Not authorized to cancel this ride',
        });
        return;
      }
      
      if (ride.status !=='requested' && ride.status !=='matched') {
        res.status(400).json({
          success: false,
          message:'Cannot cancel ride at this stage',
        });
        return;
      }
      
      ride.status ='cancelled';
      ride.cancelledAt = new Date();
      ride.cancellationReason = reason ||'Cancelled by passenger';
      await ride.save();
      
      res.json({
        success: true,
        message:'Ride cancelled successfully',
        data: ride,
      });
    } catch (error: any) {
      res.status(500).json({
        success: false,
        message:'Failed to cancel ride',
        error: error.message,
      });
    }
  }

  async rateRide(req: AuthRequest, res: Response): Promise<void> {
    try {
      const { rideId } = req.params;
      const { rating, review } = req.body;
      
      const ride = await Ride.findById(rideId);
      
      if (!ride) {
        res.status(404).json({
          success: false,
          message:'Ride not found',
        });
        return;
      }
      
      if (ride.passenger.toString() !== req.user._id.toString()) {
        res.status(403).json({
          success: false,
          message:'Not authorized to rate this ride',
        });
        return;
      }
      
      if (ride.status !=='completed') {
        res.status(400).json({
          success: false,
          message:'Cannot rate ride that is not completed',
        });
        return;
      }
      
      ride.rating = rating;
      ride.review = review;
      await ride.save();
      
      // Update driver rating
      if (ride.driver) {
        const driver = await User.findById(ride.driver);
        if (driver) {
          const allRides = await Ride.find({ driver: ride.driver, rating: { $ne: null } });
          const totalRating = allRides.reduce((sum, r) => sum + (r.rating || 0), 0);
          driver.rating = totalRating / allRides.length;
          await driver.save();
        }
      }
      
      res.json({
        success: true,
        message:'Ride rated successfully',
        data: ride,
      });
    } catch (error: any) {
      res.status(500).json({
        success: false,
        message:'Failed to rate ride',
        error: error.message,
      });
    }
  }

  async getNearbyDrivers(req: Request, res: Response): Promise<void> {
    try {
      const { lat, lng, radius = 5 } = req.query;
      
      if (!lat || !lng) {
        res.status(400).json({
          success: false,
          message:'Latitude and longitude are required',
        });
        return;
      }
      
      // Find nearby available drivers
      const drivers = await User.find({
        isDriver: true,
       'driverProfile.isAvailable': true,
       'driverProfile.location': {
          $near: {
            $geometry: {
              type:'Point',
              coordinates: [parseFloat(lng as string), parseFloat(lat as string)],
            },
            $maxDistance: parseFloat(radius as string) * 1000,
          },
        },
      }).limit(10);
      
      res.json({
        success: true,
        data: drivers,
        count: drivers.length,
      });
    } catch (error: any) {
      res.status(500).json({
        success: false,
        message:'Failed to get nearby drivers',
        error: error.message,
      });
    }
  }
}