export interface AuthRequest {
  phoneNumber: string;
  code?: string;
  fullName?: string;
  email?: string;
}

export interface RideRequest {
  pickupLocation: {
    lat: number;
    lng: number;
    address: string;
  };
  dropoffLocation: {
    lat: number;
    lng: number;
    address: string;
  };
  passengerCount: number;
  paymentMethod: 'cash' | 'card' | 'wallet';
  fare?: number;
}

export interface DriverLocation {
  driverId: string;
  location: {
    lat: number;
    lng: number;
  };
  isAvailable: boolean;
}

export interface RideUpdate {
  rideId: string;
  status: string;
  driverLocation?: {
    lat: number;
    lng: number;
  };
}

export interface NotificationPayload {
  userId: string;
  title: string;
  body: string;
  data?: Record<string, any>;
}

export interface ApiResponse<T = any> {
  success: boolean;
  message: string;
  data?: T;
  error?: string;
  errors?: Record<string, string[]>;
}