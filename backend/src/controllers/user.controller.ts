import { Request, Response } from 'express';
import { User, IUser } from '../models/User';
import { Ride } from '../models/Ride';

export class UserController {
  async getAllUsers(_req: Request, res: Response): Promise<void> {
    try {
      const users = await User.find();
      
      // Remove sensitive fields manually (instead of .select())
      const sanitizedUsers = users.map(user => {
        const { id, phoneNumber, fullName, email, isVerified, rating, totalRides, isDriver, avatar, createdAt } = user;
        return { id, phoneNumber, fullName, email, isVerified, rating, totalRides, isDriver, avatar, createdAt };
      });
      
      res.json({
        success: true,
        data: sanitizedUsers
      });
    } catch (error: any) {
      console.error('Error fetching users:', error);
      res.status(500).json({
        success: false,
        message: 'Failed to fetch users',
        error: error.message
      });
    }
  }

  async getUserById(req: Request, res: Response): Promise<void> {
    try {
      const user = await User.findById(req.params.id);
      
      if (!user) {
        res.status(404).json({
          success: false,
          message: 'User not found'
        });
        return;
      }
      
      // Remove sensitive fields manually
      const { id, phoneNumber, fullName, email, isVerified, rating, totalRides, isDriver, avatar, driverProfile, preferences, createdAt } = user;
      
      res.json({
        success: true,
        data: { id, phoneNumber, fullName, email, isVerified, rating, totalRides, isDriver, avatar, driverProfile, preferences, createdAt }
      });
    } catch (error: any) {
      console.error('Error fetching user:', error);
      res.status(500).json({
        success: false,
        message: 'Failed to fetch user',
        error: error.message
      });
    }
  }

  async updateUser(req: Request, res: Response): Promise<void> {
    try {
      const { id } = req.params;
      const { fullName, email, avatar, preferences } = req.body;

      // Build update data
      const updateData: Partial<IUser> = {};
      if (fullName) updateData.fullName = fullName;
      if (email) updateData.email = email;
      if (avatar) updateData.avatar = avatar;
      if (preferences) updateData.preferences = preferences;

      const user = await User.findByIdAndUpdate(id, updateData);
      
      if (!user) {
        res.status(404).json({
          success: false,
          message: 'User not found'
        });
        return;
      }
      
      // Get the updated user
      const updatedUser = await User.findById(id);
      
      res.json({
        success: true,
        data: updatedUser
      });
    } catch (error: any) {
      console.error('Error updating user:', error);
      res.status(500).json({
        success: false,
        message: 'Failed to update user',
        error: error.message
      });
    }
  }

  async deleteUser(req: Request, res: Response): Promise<void> {
    try {
      const { id } = req.params;
      const user = await User.findByIdAndDelete(id);
      
      if (!user) {
        res.status(404).json({
          success: false,
          message: 'User not found'
        });
        return;
      }
      
      res.json({
        success: true,
        message: 'User deleted successfully'
      });
    } catch (error: any) {
      console.error('Error deleting user:', error);
      res.status(500).json({
        success: false,
        message: 'Failed to delete user',
        error: error.message
      });
    }
  }

  async getUserRides(req: Request, res: Response): Promise<void> {
    try {
      const { id } = req.params;
      
      // Check if user exists
      const user = await User.findById(id);
      if (!user) {
        res.status(404).json({
          success: false,
          message: 'User not found'
        });
        return;
      }
      
      const rides = await Ride.find({ passengerId: id });
      
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
      console.error('Error fetching user rides:', error);
      res.status(500).json({
        success: false,
        message: 'Failed to fetch user rides',
        error: error.message
      });
    }
  }

  // Additional methods for profile management
  async getProfile(req: Request, res: Response): Promise<void> {
    try {
      const userId = (req as any).user?.id;
      
      if (!userId) {
        res.status(401).json({
          success: false,
          message: 'User not authenticated'
        });
        return;
      }

      const user = await User.findById(userId);
      
      if (!user) {
        res.status(404).json({
          success: false,
          message: 'User not found'
        });
        return;
      }

      const { id, phoneNumber, fullName, email, isVerified, rating, totalRides, isDriver, avatar, driverProfile, preferences, createdAt } = user;
      
      res.json({
        success: true,
        data: { id, phoneNumber, fullName, email, isVerified, rating, totalRides, isDriver, avatar, driverProfile, preferences, createdAt }
      });
    } catch (error: any) {
      console.error('Error getting profile:', error);
      res.status(500).json({
        success: false,
        message: 'Failed to get profile',
        error: error.message
      });
    }
  }

  async updateProfile(req: Request, res: Response): Promise<void> {
    try {
      const userId = (req as any).user?.id;
      
      if (!userId) {
        res.status(401).json({
          success: false,
          message: 'User not authenticated'
        });
        return;
      }

      const { fullName, email, avatar, preferences } = req.body;

      const updateData: Partial<IUser> = {};
      if (fullName) updateData.fullName = fullName;
      if (email) updateData.email = email;
      if (avatar) updateData.avatar = avatar;
      if (preferences) updateData.preferences = preferences;

      const user = await User.findByIdAndUpdate(userId, updateData);
      
      if (!user) {
        res.status(404).json({
          success: false,
          message: 'User not found'
        });
        return;
      }
      
      const updatedUser = await User.findById(userId);
      
      res.json({
        success: true,
        data: updatedUser
      });
    } catch (error: any) {
      console.error('Error updating profile:', error);
      res.status(500).json({
        success: false,
        message: 'Failed to update profile',
        error: error.message
      });
    }
  }

  async updateDriverProfile(req: Request, res: Response): Promise<void> {
    try {
      const userId = (req as any).user?.id;
      
      if (!userId) {
        res.status(401).json({
          success: false,
          message: 'User not authenticated'
        });
        return;
      }

      const { vehicleType, plateNumber, isAvailable } = req.body;

      // First get the current user
      const user = await User.findById(userId);
      if (!user) {
        res.status(404).json({
          success: false,
          message: 'User not found'
        });
        return;
      }

      // Build driver profile
      const driverProfile = {
        vehicleType: vehicleType || user.driverProfile?.vehicleType || '',
        plateNumber: plateNumber || user.driverProfile?.plateNumber || '',
        isAvailable: isAvailable ?? user.driverProfile?.isAvailable ?? true,
        location: user.driverProfile?.location || { lat: 0, lng: 0 },
      };

      const updatedUser = await User.findByIdAndUpdate(userId, {
        isDriver: true,
        driverProfile,
      });
      
      res.json({
        success: true,
        message: 'Driver profile updated successfully',
        data: updatedUser
      });
    } catch (error: any) {
      console.error('Error updating driver profile:', error);
      res.status(500).json({
        success: false,
        message: 'Failed to update driver profile',
        error: error.message
      });
    }
  }

  async updateDriverLocation(req: Request, res: Response): Promise<void> {
    try {
      const userId = (req as any).user?.id;
      
      if (!userId) {
        res.status(401).json({
          success: false,
          message: 'User not authenticated'
        });
        return;
      }

      const { lat, lng } = req.body;

      if (lat === undefined || lng === undefined) {
        res.status(400).json({
          success: false,
          message: 'Latitude and longitude are required'
        });
        return;
      }

      const updatedUser = await User.updateDriverLocation(userId, lat, lng);
      
      if (!updatedUser) {
        res.status(404).json({
          success: false,
          message: 'User not found or not a driver'
        });
        return;
      }
      
      res.json({
        success: true,
        message: 'Driver location updated successfully',
        data: updatedUser
      });
    } catch (error: any) {
      console.error('Error updating driver location:', error);
      res.status(500).json({
        success: false,
        message: 'Failed to update driver location',
        error: error.message
      });
    }
  }

  async updateDriverAvailability(req: Request, res: Response): Promise<void> {
    try {
      const userId = (req as any).user?.id;
      
      if (!userId) {
        res.status(401).json({
          success: false,
          message: 'User not authenticated'
        });
        return;
      }

      const { isAvailable } = req.body;

      if (isAvailable === undefined) {
        res.status(400).json({
          success: false,
          message: 'isAvailable is required'
        });
        return;
      }

      const updatedUser = await User.updateDriverAvailability(userId, isAvailable);
      
      if (!updatedUser) {
        res.status(404).json({
          success: false,
          message: 'User not found or not a driver'
        });
        return;
      }
      
      res.json({
        success: true,
        message: `Driver ${isAvailable ? 'available' : 'unavailable'} updated successfully`,
        data: updatedUser
      });
    } catch (error: any) {
      console.error('Error updating driver availability:', error);
      res.status(500).json({
        success: false,
        message: 'Failed to update driver availability',
        error: error.message
      });
    }
  }
}