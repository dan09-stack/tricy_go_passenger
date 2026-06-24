// src/controllers/user.controller.ts
import { Request, Response } from 'express';
import { User } from '../models/User';

export class UserController {
  async getAllUsers(req: Request, res: Response): Promise<void> {
    try {
      const users = await User.find().select('-__v');
      res.json({
        success: true,
        data: users
      });
    } catch (error: any) {
      res.status(500).json({
        success: false,
        message: 'Failed to fetch users',
        error: error.message
      });
    }
  }

  async getUserById(req: Request, res: Response): Promise<void> {
    try {
      const user = await User.findById(req.params.id).select('-__v');
      
      if (!user) {
        res.status(404).json({
          success: false,
          message: 'User not found'
        });
        return;
      }
      
      res.json({
        success: true,
        data: user
      });
    } catch (error: any) {
      res.status(500).json({
        success: false,
        message: 'Failed to fetch user',
        error: error.message
      });
    }
  }

  async updateUser(req: Request, res: Response): Promise<void> {
    try {
      const user = await User.findByIdAndUpdate(
        req.params.id,
        req.body,
        { new: true, runValidators: true }
      ).select('-__v');
      
      if (!user) {
        res.status(404).json({
          success: false,
          message: 'User not found'
        });
        return;
      }
      
      res.json({
        success: true,
        data: user
      });
    } catch (error: any) {
      res.status(500).json({
        success: false,
        message: 'Failed to update user',
        error: error.message
      });
    }
  }

  async deleteUser(req: Request, res: Response): Promise<void> {
    try {
      const user = await User.findByIdAndDelete(req.params.id);
      
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
      res.status(500).json({
        success: false,
        message: 'Failed to delete user',
        error: error.message
      });
    }
  }

  async getUserRides(req: Request, res: Response): Promise<void> {
    try {
      // Assuming you have a Ride model
      const Ride = require('../models/Ride').Ride;
      const rides = await Ride.find({ passengerId: req.params.id });
      
      res.json({
        success: true,
        data: rides
      });
    } catch (error: any) {
      res.status(500).json({
        success: false,
        message: 'Failed to fetch user rides',
        error: error.message
      });
    }
  }
}