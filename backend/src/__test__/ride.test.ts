import request from 'supertest';
import { app } from '../index';
import { User } from '../models/User';
import { Ride } from '../models/Ride';

describe('Ride API Tests', () => {
  let server: any;
  let authToken: string;
  let testUserId: string;
  let rideId: string;

  beforeAll(async () => {
    server = app.listen(4001);
    
    // Create a test user
    const user = await User.create({
      phoneNumber: '09123456789',
      fullName: 'Test User',
      isVerified: true,
    });
    
    testUserId = user.id!;
    
    // Get auth token (using the dev endpoint or actual auth)
    // For testing, we'll use the dev login
    const loginResponse = await request(app)
      .post('/api/auth/dev-login')
      .send({
        phoneNumber: '09123456789',
        fullName: 'Test User'
      });
    
    authToken = loginResponse.body.data.token;
  });

  afterAll(async () => {
    // Clean up
    await User.deleteMany({});
    await Ride.deleteMany({});
    if (server) {
      server.close();
    }
  });

  beforeEach(async () => {
    // Clear rides before each test
    await Ride.deleteMany({});
  });

  describe('POST /api/rides/request', () => {
    it('should request a ride successfully', async () => {
      const response = await request(app)
        .post('/api/rides/request')
        .set('Authorization', `Bearer ${authToken}`)
        .send({
          pickupLocation: {
            lat: 14.5995,
            lng: 120.9842,
            address: '123 Main St'
          },
          dropoffLocation: {
            lat: 14.6025,
            lng: 120.9872,
            address: '456 Central Ave'
          },
          passengerCount: 2,
          paymentMethod: 'cash'
        });

      expect(response.status).toBe(200);
      expect(response.body.success).toBe(true);
      expect(response.body.data).toHaveProperty('id');
      expect(response.body.data.status).toBe('requested');
      
      rideId = response.body.data.id;
    });

    it('should reject invalid passenger count', async () => {
      const response = await request(app)
        .post('/api/rides/request')
        .set('Authorization', `Bearer ${authToken}`)
        .send({
          pickupLocation: { 
            lat: 14.5995, 
            lng: 120.9842, 
            address: 'Test' 
          },
          dropoffLocation: { 
            lat: 14.6025, 
            lng: 120.9872, 
            address: 'Test' 
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
          pickupLocation: { 
            lat: 14.5995, 
            lng: 120.9842, 
            address: 'Test' 
          },
          dropoffLocation: { 
            lat: 14.6025, 
            lng: 120.9872, 
            address: 'Test' 
          },
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
        passengerId: testUserId,
        pickupLocation: { 
          lat: 14.5995, 
          lng: 120.9842, 
          address: 'Test' 
        },
        dropoffLocation: { 
          lat: 14.6025, 
          lng: 120.9872, 
          address: 'Test' 
        },
        passengerCount: 1,
        paymentMethod: 'cash',
        status: 'requested'
      });

      const response = await request(app)
        .get(`/api/rides/${ride.id}`)
        .set('Authorization', `Bearer ${authToken}`);

      expect(response.status).toBe(200);
      expect(response.body.success).toBe(true);
      expect(response.body.data).toHaveProperty('id', ride.id);
    });

    it('should return 404 for non-existent ride', async () => {
      const response = await request(app)
        .get('/api/rides/non-existent-id')
        .set('Authorization', `Bearer ${authToken}`);

      expect(response.status).toBe(404);
    });
  });

  describe('POST /api/rides/:rideId/cancel', () => {
    it('should cancel a ride', async () => {
      // Create a ride first
      const ride = await Ride.create({
        passengerId: testUserId,
        pickupLocation: { 
          lat: 14.5995, 
          lng: 120.9842, 
          address: 'Test' 
        },
        dropoffLocation: { 
          lat: 14.6025, 
          lng: 120.9872, 
          address: 'Test' 
        },
        passengerCount: 1,
        paymentMethod: 'cash',
        status: 'requested'
      });

      const response = await request(app)
        .post(`/api/rides/${ride.id}/cancel`)
        .set('Authorization', `Bearer ${authToken}`);

      expect(response.status).toBe(200);
      expect(response.body.success).toBe(true);
      expect(response.body.message).toBe('Ride cancelled successfully');
    });
  });

  describe('POST /api/rides/:rideId/rate', () => {
    it('should rate a completed ride', async () => {
      // Create a completed ride first
      const ride = await Ride.create({
        passengerId: testUserId,
        pickupLocation: { 
          lat: 14.5995, 
          lng: 120.9842, 
          address: 'Test' 
        },
        dropoffLocation: { 
          lat: 14.6025, 
          lng: 120.9872, 
          address: 'Test' 
        },
        passengerCount: 1,
        paymentMethod: 'cash',
        status: 'completed'
      });

      const response = await request(app)
        .post(`/api/rides/${ride.id}/rate`)
        .set('Authorization', `Bearer ${authToken}`)
        .send({
          rating: 4.5,
          review: 'Great ride!'
        });

      expect(response.status).toBe(200);
      expect(response.body.success).toBe(true);
      expect(response.body.message).toBe('Ride rated successfully');
    });

    it('should not rate a non-completed ride', async () => {
      // Create a ride that's not completed
      const ride = await Ride.create({
        passengerId: testUserId,
        pickupLocation: { 
          lat: 14.5995, 
          lng: 120.9842, 
          address: 'Test' 
        },
        dropoffLocation: { 
          lat: 14.6025, 
          lng: 120.9872, 
          address: 'Test' 
        },
        passengerCount: 1,
        paymentMethod: 'cash',
        status: 'requested'
      });

      const response = await request(app)
        .post(`/api/rides/${ride.id}/rate`)
        .set('Authorization', `Bearer ${authToken}`)
        .send({
          rating: 4.5,
          review: 'Great ride!'
        });

      expect(response.status).toBe(400);
      expect(response.body.success).toBe(false);
      expect(response.body.message).toBe('Ride must be completed before rating');
    });
  });

  describe('GET /api/rides/history', () => {
    it('should get ride history for authenticated user', async () => {
      // Create some rides
      await Ride.create({
        passengerId: testUserId,
        pickupLocation: { 
          lat: 14.5995, 
          lng: 120.9842, 
          address: 'Test 1' 
        },
        dropoffLocation: { 
          lat: 14.6025, 
          lng: 120.9872, 
          address: 'Test 2' 
        },
        passengerCount: 1,
        paymentMethod: 'cash',
        status: 'completed'
      });

      await Ride.create({
        passengerId: testUserId,
        pickupLocation: { 
          lat: 14.5995, 
          lng: 120.9842, 
          address: 'Test 3' 
        },
        dropoffLocation: { 
          lat: 14.6025, 
          lng: 120.9872, 
          address: 'Test 4' 
        },
        passengerCount: 2,
        paymentMethod: 'cash',
        status: 'cancelled'
      });

      const response = await request(app)
        .get('/api/rides/history')
        .set('Authorization', `Bearer ${authToken}`);

      expect(response.status).toBe(200);
      expect(response.body.success).toBe(true);
      expect(response.body.data).toBeInstanceOf(Array);
      expect(response.body.data.length).toBe(2);
    });

    it('should require authentication for history', async () => {
      const response = await request(app)
        .get('/api/rides/history');

      expect(response.status).toBe(401);
    });
  });
});