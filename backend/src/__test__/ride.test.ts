import request from 'supertest';
import mongoose from 'mongoose';
import { app } from '../index';
import { User } from '../models/User';
import { Ride } from '../models/Ride';
import jwt from 'jsonwebtoken';

describe('Ride Routes', () => {
  let token: string;
  let userId: string;

  beforeAll(async () => {
    await mongoose.connect(process.env.MONGODB_URI_TEST || 'mongodb://localhost:27017/test');
  });

  afterAll(async () => {
    await mongoose.connection.close();
  });

  beforeEach(async () => {
    await User.deleteMany({});
    await Ride.deleteMany({});
    
    // Create a test user and get token
    const user = await User.create({
      phoneNumber: '1234567890',
      fullName: 'Test User',
      isVerified: true
    });
    userId = user._id.toString();
    token = jwt.sign(
      { userId: user._id, phoneNumber: user.phoneNumber },
      process.env.JWT_SECRET || 'secret',
      { expiresIn: '7d' }
    );
  });

  describe('POST /api/rides/request', () => {
    it('should request a ride successfully', async () => {
      const response = await request(app)
        .post('/api/rides/request')
        .set('Authorization', `Bearer ${token}`)
        .send({
          pickupLocation: {
            lat: 14.5995,
            lng: 120.9842,
            address: '123 Main St, Manila'
          },
          dropoffLocation: {
            lat: 14.6025,
            lng: 120.9872,
            address: '456 Central Ave, Manila'
          },
          passengerCount: 2,
          paymentMethod: 'cash'
        });

      expect(response.status).toBe(200);
      expect(response.body.success).toBe(true);
      expect(response.body.data).toHaveProperty('rideId');
      expect(response.body.data.status).toBe('searching');
    });

    it('should return error for invalid passenger count', async () => {
      const response = await request(app)
        .post('/api/rides/request')
        .set('Authorization', `Bearer ${token}`)
        .send({
          pickupLocation: {
            lat: 14.5995,
            lng: 120.9842,
            address: '123 Main St, Manila'
          },
          dropoffLocation: {
            lat: 14.6025,
            lng: 120.9872,
            address: '456 Central Ave, Manila'
          },
          passengerCount: 5, // Invalid (max 4)
          paymentMethod: 'cash'
        });

      expect(response.status).toBe(400);
      expect(response.body.errors).toBeDefined();
    });

    it('should require authentication', async () => {
      const response = await request(app)
        .post('/api/rides/request')
        .send({
          pickupLocation: { lat: 14.5995, lng: 120.9842, address: 'Test' },
          dropoffLocation: { lat: 14.6025, lng: 120.9872, address: 'Test' },
          passengerCount: 1,
          paymentMethod: 'cash'
        });

      expect(response.status).toBe(401);
    });
  });

  describe('GET /api/rides/:rideId', () => {
    it('should get ride details', async () => {
      // Create a ride first
      const ride = await Ride.create({
        passengerId: userId,
        pickupLocation: { lat: 14.5995, lng: 120.9842, address: 'Test' },
        dropoffLocation: { lat: 14.6025, lng: 120.9872, address: 'Test' },
        passengerCount: 1,
        paymentMethod: 'cash',
        status: 'searching'
      });

      const response = await request(app)
        .get(`/api/rides/${ride._id}`)
        .set('Authorization', `Bearer ${token}`);

      expect(response.status).toBe(200);
      expect(response.body.success).toBe(true);
      expect(response.body.data).toHaveProperty('_id', ride._id.toString());
    });

    it('should return 404 for non-existent ride', async () => {
      const response = await request(app)
        .get(`/api/rides/507f1f77bcf86cd799439011`)
        .set('Authorization', `Bearer ${token}`);

      expect(response.status).toBe(404);
    });
  });
});