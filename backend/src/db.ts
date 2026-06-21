import { User, Driver, Ride } from './models/interfaces';

export class MockDatabase {
  public users: Map<string, User> = new Map();
  public drivers: Map<string, Driver> = new Map();
  public rides: Map<string, Ride> = new Map();

  constructor() {
    this.seed();
  }

  private seed() {
    // Seed standard admin user
    const adminId = 'admin-uuid-1';
    this.users.set(adminId, {
      id: adminId,
      phone: '+1234567890',
      fullName: 'Admin TricyGo',
      role: 'admin',
      averageRating: 5.0,
      isVerified: true,
      isActive: true,
      createdAt: new Date(),
    });

    // Seed dummy passenger
    const passengerId = 'passenger-uuid-1';
    this.users.set(passengerId, {
      id: passengerId,
      phone: '+1987654321',
      fullName: 'John Doe',
      role: 'passenger',
      averageRating: 4.8,
      isVerified: true,
      isActive: true,
      createdAt: new Date(),
    });

    // Seed dummy driver user and driver record
    const driverUserId = 'driver-user-uuid-1';
    const driverId = 'driver-uuid-1';
    this.users.set(driverUserId, {
      id: driverUserId,
      phone: '+1555444333',
      fullName: 'Speedy Tricycler',
      role: 'driver',
      averageRating: 4.9,
      isVerified: true,
      isActive: true,
      createdAt: new Date(),
    });

    this.drivers.set(driverId, {
      id: driverId,
      userId: driverUserId,
      licenseNumber: 'LIC-998877',
      vehiclePlate: 'TRI-7788',
      vehicleModel: 'Bajaj RE 4S',
      vehicleColor: 'Yellow',
      isAvailable: true,
      currentLocation: { lat: 14.5995, lng: 120.9842 } // Manila default
    });
  }
}

export const db = new MockDatabase();
