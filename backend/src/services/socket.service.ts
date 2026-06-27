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
    // Authentication middleware - allow connections without token in development
    this.io.use(async (socket: AuthenticatedSocket, next) => {
      try {
        const token = socket.handshake.auth.token;
        
        // In development, allow connections without token
        if (!token) {
          console.log('⚠️ No token provided, allowing connection for development');
          return next();
        }

        // Verify JWT token
        const decoded = await this.verifyToken(token);
        if (!decoded) {
          console.log('⚠️ Invalid token, allowing connection for development');
          return next();
        }

        socket.userId = decoded.userId;
        console.log(`✅ Token verified for user: ${decoded.userId}`);
        next();
      } catch (error) {
        console.log('⚠️ Auth error, allowing connection for development');
        next();
      }
    });

    this.io.on('connection', (socket: AuthenticatedSocket) => {
      const transport = socket.conn.transport.name;
      console.log(`🔌 New client connected: ${socket.id} (transport: ${transport})`);
      
      if (socket.userId) {
        this.connectedUsers.set(socket.userId, socket.id);
        console.log(`👤 User ${socket.userId} connected`);
      }

      // Send connection confirmation
      socket.emit('connected', { 
        message: 'Connected to Socket.IO server',
        socketId: socket.id,
        userId: socket.userId || 'anonymous',
        transport: transport,
      });

      // Handle joining ride room
      socket.on('join-ride', (rideId: string) => {
        socket.join(`ride-${rideId}`);
        console.log(`🚗 User joined ride room: ride-${rideId}`);
        socket.emit('joined-ride', { rideId, message: 'Successfully joined ride' });
      });

      // Handle leaving ride room
      socket.on('leave-ride', (rideId: string) => {
        socket.leave(`ride-${rideId}`);
        console.log(`🚗 User left ride room: ride-${rideId}`);
      });

      // Handle ping/pong for keep-alive
      socket.on('ping', () => {
        socket.emit('pong', { timestamp: Date.now() });
      });

      // Handle driver location updates
      socket.on('driver-location', async (data) => {
        const { rideId, location } = data;
        try {
          // Update driver location in database
          const ride = await Ride.findById(rideId);
          if (ride && ride.id) {
            await Ride.findByIdAndUpdate(ride.id, {
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
      socket.on('disconnect', (reason) => {
        if (socket.userId) {
          this.connectedUsers.delete(socket.userId);
          console.log(`👤 User ${socket.userId} disconnected: ${reason}`);
        }
        console.log(`🔌 Client disconnected: ${socket.id} - ${reason}`);
      });
    });

    console.log('✅ Socket.IO initialized');
  }

  // Send notification to a specific user
  sendToUser(userId: string, event: string, data: any): void {
    const socketId = this.connectedUsers.get(userId);
    if (socketId) {
      this.io.to(socketId).emit(event, data);
    } else {
      console.log(`⚠️ User ${userId} not connected`);
    }
  }

  // Send notification to a ride room
  sendToRide(rideId: string, event: string, data: any): void {
    this.io.to(`ride-${rideId}`).emit(event, data);
  }

  // Verify JWT token
  private async verifyToken(token: string): Promise<any> {
    try {
      // Dynamic import for JWT
      const jwt = require('jsonwebtoken');
      const decoded = jwt.verify(token, process.env.JWT_SECRET || 'secret');
      return decoded;
    } catch (error) {
      console.log('⚠️ Token verification failed:', error);
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
    console.log(`📡 Broadcasted to all: ${event}`);
  }

  // Get connection statistics
  getStats(): any {
    return {
      totalConnections: this.connectedUsers.size,
      connectedUsers: Array.from(this.connectedUsers.keys()),
      socketIds: Array.from(this.connectedUsers.values()),
    };
  }

  // Disconnect a specific user
  disconnectUser(userId: string): void {
    const socketId = this.connectedUsers.get(userId);
    if (socketId) {
      const socket = this.io.sockets.sockets.get(socketId);
      if (socket) {
        socket.disconnect();
        console.log(`🔌 Disconnected user ${userId}`);
      }
    }
  }
}