import { Server as SocketServer, Socket } from 'socket.io';
import { Ride, IRide } from '../models/Ride';

interface AuthenticatedSocket extends Socket {
  userId?: string;
}

export class SocketService {
  private io: SocketServer;
  private connectedUsers: Map<string, string> = new Map(); // userId -> socketId

  constructor(io: SocketServer) {
    this.io = io;
  }

  initialize(): void {
    this.io.use(async (socket: AuthenticatedSocket, next) => {
      try {
        const token = socket.handshake.auth.token;
        if (!token) {
          return next(new Error('Authentication required'));
        }

        // Verify JWT token
        const decoded = await this.verifyToken(token);
        if (!decoded) {
          return next(new Error('Invalid token'));
        }

        socket.userId = decoded.userId;
        next();
      } catch (error) {
        next(new Error('Authentication failed'));
      }
    });

    this.io.on('connection', (socket: AuthenticatedSocket) => {
      console.log(`🔌 New client connected: ${socket.id}`);
      
      if (socket.userId) {
        this.connectedUsers.set(socket.userId, socket.id);
        console.log(`👤 User ${socket.userId} connected`);
      }

      // Handle joining ride room
      socket.on('join-ride', (rideId: string) => {
        socket.join(`ride-${rideId}`);
        console.log(`🚗 User joined ride room: ride-${rideId}`);
      });

      // Handle leaving ride room
      socket.on('leave-ride', (rideId: string) => {
        socket.leave(`ride-${rideId}`);
        console.log(`🚗 User left ride room: ride-${rideId}`);
      });

      // Handle driver location updates
      socket.on('driver-location', async (data) => {
        const { rideId, location } = data;
        try {
          // Update driver location in database
          const ride = await Ride.findById(rideId);
          if (ride && ride.id) {
            const updatedRide = await Ride.findByIdAndUpdate(ride.id, {
              driverLocation: {
                lat: location.lat || location.latitude,
                lng: location.lng || location.longitude,
              }
            });
          }
          
          // Broadcast to passengers in the ride room
          this.io.to(`ride-${rideId}`).emit('driver-location-update', {
            driverId: socket.userId,
            location,
          });
        } catch (error) {
          console.error('Error updating driver location:', error);
          socket.emit('error', { message: 'Failed to update location' });
        }
      });

      // Handle ride status updates
      socket.on('ride-status-update', async (data) => {
        const { rideId, status, driverLocation } = data;
        
        try {
          const ride = await Ride.findById(rideId);
          if (ride && ride.id) {
            await Ride.findByIdAndUpdate(ride.id, { 
              status,
              ...(driverLocation && {
                driverLocation: {
                  lat: driverLocation.lat || driverLocation.latitude,
                  lng: driverLocation.lng || driverLocation.longitude,
                }
              })
            });
          }
          
          this.io.to(`ride-${rideId}`).emit('ride-status-updated', {
            rideId,
            status,
            driverLocation,
          });
        } catch (error) {
          console.error('Error updating ride status:', error);
          socket.emit('error', { message: 'Failed to update ride status' });
        }
      });

      // Handle disconnect
      socket.on('disconnect', () => {
        if (socket.userId) {
          this.connectedUsers.delete(socket.userId);
          console.log(`👤 User ${socket.userId} disconnected`);
        }
        console.log(`🔌 Client disconnected: ${socket.id}`);
      });
    });
  }

  // Send notification to a specific user
  sendToUser(userId: string, event: string, data: any): void {
    const socketId = this.connectedUsers.get(userId);
    if (socketId) {
      this.io.to(socketId).emit(event, data);
    }
  }

  // Send notification to a ride room
  sendToRide(rideId: string, event: string, data: any): void {
    this.io.to(`ride-${rideId}`).emit(event, data);
  }

  // Verify JWT token
  private async verifyToken(token: string): Promise<any> {
    const jwt = require('jsonwebtoken');
    try {
      const decoded = jwt.verify(token, process.env.JWT_SECRET || 'secret');
      return decoded;
    } catch (error) {
      return null;
    }
  }

  // Get connected users count
  getConnectedUsersCount(): number {
    return this.connectedUsers.size;
  }

  // Get socket ID for a user
  getUserSocketId(userId: string): string | undefined {
    return this.connectedUsers.get(userId);
  }

  // Get all connected user IDs
  getConnectedUsers(): string[] {
    return Array.from(this.connectedUsers.keys());
  }

  // Check if a user is connected
  isUserConnected(userId: string): boolean {
    return this.connectedUsers.has(userId);
  }

  // Broadcast to all connected users
  broadcastToAll(event: string, data: any): void {
    this.io.emit(event, data);
  }
}