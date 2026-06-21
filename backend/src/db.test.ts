import { MockDatabase } from '../src/db';

describe('MockDatabase Domain Entity Tests', () => {
  let database: MockDatabase;

  beforeEach(() => {
    database = new MockDatabase();
  });

  test('should seed initial admin, passenger, and driver on initialize', () => {
    expect(database.users.size).toBeGreaterThanOrEqual(2);
    expect(database.drivers.has('driver-uuid-1')).toBe(true);

    const mainDriver = database.drivers.get('driver-uuid-1');
    expect(mainDriver?.vehicleColor).toBe('Yellow');
  });

  test('should allow inserting and fetching new ride requests successfully', () => {
    const rideId = 'test-ride-id-123';
    database.rides.set(rideId, {
      id: rideId,
      passengerId: 'passenger-uuid-1',
      pickupAddress: '123 Main Street',
      dropoffAddress: '456 Central Ave',
      passengerCount: 2,
      totalFare: 70.0,
      status: 'searching',
      requestedAt: new Date()
    });

    expect(database.rides.has(rideId)).toBe(true);
    const retrieved = database.rides.get(rideId);
    expect(retrieved?.status).toBe('searching');
    expect(retrieved?.passengerCount).toBe(2);
  });
});
