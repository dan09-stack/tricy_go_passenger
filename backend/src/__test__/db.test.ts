import mongoose from 'mongoose';
import { connectDB, disconnectDB } from '../db';

describe('Database Connection', () => {
  beforeAll(async () => {
    // Ensure we're using test environment
    process.env.NODE_ENV = 'test';
    process.env.MONGODB_URI_TEST = 'mongodb://localhost:27017/test';
  });

  afterAll(async () => {
    await disconnectDB();
  });

  it('should connect to database successfully', async () => {
    await expect(connectDB()).resolves.not.toThrow();
    expect(mongoose.connection.readyState).toBe(1); // 1 = connected
  });

  it('should disconnect from database successfully', async () => {
    await disconnectDB();
    expect(mongoose.connection.readyState).toBe(0); // 0 = disconnected
  });
});