export interface User {
  id: string;
  phone: string;
  fullName: string;
  role: 'passenger' | 'driver' | 'admin';
  avatarUrl?: string;
  averageRating: number;
  isVerified: boolean;
  isActive: boolean;
  createdAt: Date;
}

export interface Driver {
  id: string;
  userId: string;
  licenseNumber: string;
  vehiclePlate: string;
  vehicleModel: string;
  vehicleColor: string;
  isAvailable: boolean;
  currentLocation?: {
    lat: number;
    lng: number;
  };
}

export interface Ride {
  id: string;
  passengerId: string;
  driverId?: string;
  pickupAddress: string;
  dropoffAddress: string;
  passengerCount: number;
  totalFare: number;
  status: 'pending' | 'searching' | 'driver_assigned' | 'driver_arrived' | 'in_progress' | 'completed' | 'cancelled';
  requestedAt: Date;
  startedAt?: Date;
  completedAt?: Date;
}
