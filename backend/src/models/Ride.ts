import mongoose, { Schema, Document } from 'mongoose';

export interface IRide extends Document {
  passenger: mongoose.Types.ObjectId;
  driver?: mongoose.Types.ObjectId;
  status: 'requested' | 'matched' | 'en_route' | 'completed' | 'cancelled';
  pickupLocation: {
    type: string;
    coordinates: [number, number];
    address: string;
  };
  dropoffLocation: {
    type: string;
    coordinates: [number, number];
    address: string;
  };
  passengerCount: number;
  fare: number;
  distance: number;
  duration: number;
  paymentMethod: 'cash' | 'card' | 'wallet';
  paymentStatus: 'pending' | 'paid' | 'failed';
  rating?: number;
  review?: string;
  driverLocation?: {
    type: string;
    coordinates: [number, number];
  };
  startedAt?: Date;
  completedAt?: Date;
  cancelledAt?: Date;
  cancellationReason?: string;
  createdAt: Date;
  updatedAt: Date;
}

const RideSchema = new Schema<IRide>(
  {
    passenger: {
      type: Schema.Types.ObjectId,
      ref: 'User',
      required: true,
    },
    driver: {
      type: Schema.Types.ObjectId,
      ref: 'User',
    },
    status: {
      type: String,
      enum: ['requested', 'matched', 'en_route', 'completed', 'cancelled'],
      default: 'requested',
    },
    pickupLocation: {
      type: {
        type: String,
        enum: ['Point'],
        default: 'Point',
      },
      coordinates: {
        type: [Number],
        required: true,
      },
      address: {
        type: String,
        required: true,
      },
    },
    dropoffLocation: {
      type: {
        type: String,
        enum: ['Point'],
        default: 'Point',
      },
      coordinates: {
        type: [Number],
        required: true,
      },
      address: {
        type: String,
        required: true,
      },
    },
    passengerCount: {
      type: Number,
      required: true,
      min: 1,
      max: 4,
    },
    fare: {
      type: Number,
      required: true,
    },
    distance: {
      type: Number,
      required: true,
    },
    duration: {
      type: Number,
      required: true,
    },
    paymentMethod: {
      type: String,
      enum: ['cash', 'card', 'wallet'],
      default: 'cash',
    },
    paymentStatus: {
      type: String,
      enum: ['pending', 'paid', 'failed'],
      default: 'pending',
    },
    rating: {
      type: Number,
      min: 0,
      max: 5,
    },
    review: {
      type: String,
      trim: true,
    },
    driverLocation: {
      type: {
        type: String,
        enum: ['Point'],
        default: 'Point',
      },
      coordinates: {
        type: [Number],
        default: [0, 0],
      },
    },
    startedAt: Date,
    completedAt: Date,
    cancelledAt: Date,
    cancellationReason: String,
  },
  {
    timestamps: true,
  }
);

// Indexes for efficient queries
RideSchema.index({ 'pickupLocation.coordinates': '2dsphere' });
RideSchema.index({ 'driverLocation.coordinates': '2dsphere' });
RideSchema.index({ passenger: 1, status: 1 });
RideSchema.index({ driver: 1, status: 1 });
RideSchema.index({ createdAt: -1 });

export const Ride = mongoose.model<IRide>('Ride', RideSchema);