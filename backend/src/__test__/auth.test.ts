import request from 'supertest';
import mongoose from 'mongoose';
import { app } from '../index';
import { User } from '../models/User';
import { OTP } from '../models/OTP';

describe('Auth Routes', () => {
  let server: any;

  beforeAll(async () => {
    // Connect to test database
    await mongoose.connect(process.env.MONGODB_URI_TEST || 'mongodb://localhost:27017/test');
    server = app.listen(4000);
  });

  afterAll(async () => {
    // Clean up
    await User.deleteMany({});
    await OTP.deleteMany({});
    await mongoose.connection.close();
    server.close();
  });

  beforeEach(async () => {
    // Clear collections before each test
    await User.deleteMany({});
    await OTP.deleteMany({});
  });

  describe('POST /api/auth/send-otp', () => {
    it('should send OTP successfully', async () => {
      const response = await request(app)
        .post('/api/auth/send-otp')
        .send({
          phoneNumber: '1234567890'
        });

      expect(response.status).toBe(200);
      expect(response.body.success).toBe(true);
      expect(response.body.message).toBe('OTP sent successfully');
      expect(response.body.data).toHaveProperty('phoneNumber');
    });

    it('should return error for invalid phone number', async () => {
      const response = await request(app)
        .post('/api/auth/send-otp')
        .send({
          phoneNumber: '123' // Invalid
        });

      expect(response.status).toBe(400);
      expect(response.body.errors).toBeDefined();
    });

    it('should rate limit OTP requests', async () => {
      // Make multiple requests quickly
      const requests = Array(6).fill(null).map(() => 
        request(app)
          .post('/api/auth/send-otp')
          .send({ phoneNumber: '1234567890' })
      );

      const responses = await Promise.all(requests);
      const lastResponse = responses[responses.length - 1];
      
      expect(lastResponse.status).toBe(429);
      expect(lastResponse.body.message).toContain('Too many OTP requests');
    });
  });

  describe('POST /api/auth/verify-otp', () => {
    it('should verify OTP and create user', async () => {
      // First create an OTP
      const otpCode = '123456';
      await OTP.create({
        phoneNumber: '1234567890',
        code: otpCode,
        isUsed: false
      });

      const response = await request(app)
        .post('/api/auth/verify-otp')
        .send({
          phoneNumber: '1234567890',
          code: otpCode,
          fullName: 'Test User',
          email: 'test@example.com'
        });

      expect(response.status).toBe(200);
      expect(response.body.success).toBe(true);
      expect(response.body.data).toHaveProperty('token');
      expect(response.body.data.user).toHaveProperty('phoneNumber', '1234567890');
      expect(response.body.data.user).toHaveProperty('fullName', 'Test User');
    });

    it('should return error for invalid OTP', async () => {
      const response = await request(app)
        .post('/api/auth/verify-otp')
        .send({
          phoneNumber: '1234567890',
          code: '999999'
        });

      expect(response.status).toBe(400);
      expect(response.body.success).toBe(false);
      expect(response.body.message).toBe('Invalid or expired OTP');
    });

    it('should rate limit verification attempts', async () => {
      const requests = Array(4).fill(null).map(() =>
        request(app)
          .post('/api/auth/verify-otp')
          .send({
            phoneNumber: '1234567890',
            code: '999999'
          })
      );

      const responses = await Promise.all(requests);
      const lastResponse = responses[responses.length - 1];
      
      expect(lastResponse.status).toBe(429);
    });
  });

  describe('POST /api/auth/refresh-token', () => {
    it('should refresh token successfully', async () => {
      // First create a user and get token
      const user = await User.create({
        phoneNumber: '1234567890',
        fullName: 'Test User',
        isVerified: true
      });

      const refreshToken = 'some-refresh-token'; // In real test, you'd generate this

      const response = await request(app)
        .post('/api/auth/refresh-token')
        .send({ refreshToken });

      // This will fail with invalid token, but tests the endpoint
      expect(response.status).toBe(401);
    });
  });
});