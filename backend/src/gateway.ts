import { Server, Socket } from 'socket.io';
import { db } from './db';
import { Ride } from './models/interfaces';
import { v4 as uuidv4 } from 'uuid';

export class SocketGateway {
  private io: Server;

  constructor(io: Server) {
    this.io = io;
  }

  public init() {
    this.io.on('connection', (socket: Socket) => {
      console.log(`Client connected: ${socket.id}`);

      // Handle user registration in a specific socket room
      socket.on('join_room', (data: { userId: string; role: string }) => {
        socket.join(data.userId);
        if (data.role === 'driver') {
          socket.join('drivers_pool');
        }
        console.log(`User ${data.userId} (${data.role}) joined room.`);
      });

      // 1. ride.request
      socket.on('ride.request', (data: { passengerId: string; pickup: string; dropoff: string; count: number }) => {
        const newRide: Ride = {
          id: uuidv4(),
          passengerId: data.passengerId,
          pickupAddress: data.pickup,
          dropoffAddress: data.dropoff,
          passengerCount: data.count || 1,
          totalFare: 50.0 + (data.count || 1) * 10, // flat base price estimation
          status: 'searching',
          requestedAt: new Date(),
        };

        db.rides.set(newRide.id, newRide);
        console.log(`New Ride Request: ${newRide.id} by passenger ${data.passengerId}`);

        // Broadcast the active ride to all available drivers
        this.io.to('drivers_pool').emit('ride.available', newRide);
        // Reply back to passenger with current ride state
        socket.emit('ride.status_updated', newRide);
      });

      // 2. ride.accept
      socket.on('ride.accept', (data: { rideId: string; driverId: string }) => {
        const ride = db.rides.get(data.rideId);
        if (ride && ride.status === 'searching') {
          ride.driverId = data.driverId;
          ride.status = 'driver_assigned';
          db.rides.set(ride.id, ride);

          console.log(`Ride ${ride.id} accepted by driver ${data.driverId}`);
          
          // Inform passenger and driver
          this.io.to(ride.passengerId).emit('ride.status_updated', ride);
          this.io.to(ride.passengerId).emit('ride.driver_assigned', { driverId: data.driverId });
          socket.emit('ride.status_updated', ride);
        } else {
          socket.emit('ride.error', { message: 'Ride no longer available or invalid.' });
        }
      });

      // 3. ride.update_location (Live tracking coordinates broadcast)
      socket.on('ride.update_location', (data: { driverId: string; rideId?: string; lat: number; lng: number }) => {
        const driver = db.drivers.get(data.driverId);
        if (driver) {
          driver.currentLocation = { lat: data.lat, lng: data.lng };
          db.drivers.set(data.driverId, driver);
        }

        if (data.rideId) {
          const ride = db.rides.get(data.rideId);
          if (ride) {
            this.io.to(ride.passengerId).emit('ride.location_tracked', { lat: data.lat, lng: data.lng });
          }
        }
      });

      // 4. ride.complete
      socket.on('ride.complete', (data: { rideId: string }) => {
        const ride = db.rides.get(data.rideId);
        if (ride) {
          ride.status = 'completed';
          ride.completedAt = new Date();
          db.rides.set(ride.id, ride);

          console.log(`Ride ${ride.id} completed successfully.`);
          this.io.to(ride.passengerId).emit('ride.status_updated', ride);
          if (ride.driverId) {
            this.io.to(ride.driverId).emit('ride.status_updated', ride);
          }
        }
      });

      socket.on('disconnect', () => {
        console.log(`Client disconnected: ${socket.id}`);
      });
    });
  }
}
