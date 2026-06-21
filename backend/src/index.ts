import express, { Request, Response } from 'express';
import http from 'http';
import { Server } from 'socket.io';
import cors from 'cors';
import dotenv from 'dotenv';
import { db } from './db';
import { SocketGateway } from './gateway';

dotenv.config();

const app = express();
const server = http.createServer(app);
const io = new Server(server, {
  cors: {
    origin: '*',
    methods: ['GET', 'POST']
  }
});

app.use(cors());
app.use(express.json());

const PORT = process.env.PORT || 3000;

// --- REST API REST Endpoints ---

// 1. Auth Endpoint
app.post('/api/auth/otp/request', (req: Request, res: Response) => {
  const { phone } = req.body;
  if (!phone) return res.status(400).json({ error: 'Phone number required' });
  return res.json({ success: true, message: 'OTP code sent successfully (Mocked: 123456)' });
});

app.post('/api/auth/otp/verify', (req: Request, res: Response) => {
  const { phone, code } = req.body;
  if (!phone || !code) return res.status(400).json({ error: 'Phone and code required' });

  // Find user by phone, or create passenger on the fly
  let user = Array.from(db.users.values()).find(u => u.phone === phone);
  if (!user) {
    user = {
      id: `user-${Date.now()}`,
      phone,
      fullName: 'New TricyGo User',
      role: 'passenger',
      averageRating: 5.0,
      isVerified: true,
      isActive: true,
      createdAt: new Date()
    };
    db.users.set(user.id, user);
  }

  return res.json({
    success: true,
    token: 'mock-jwt-token',
    user
  });
});

// 2. Rides Estimation & History
app.post('/api/rides/estimate', (req: Request, res: Response) => {
  const { passengerCount } = req.body;
  const count = passengerCount || 1;
  const baseFare = 50.0;
  const totalFare = baseFare + count * 10;
  return res.json({ baseFare, totalFare, currency: 'PHP' });
});

app.get('/api/rides/history/:userId', (req: Request, res: Response) => {
  const { userId } = req.params;
  const history = Array.from(db.rides.values()).filter(
    r => r.passengerId === userId || r.driverId === userId
  );
  return res.json(history);
});

// 3. Admin Dashboard Statistics Metrics Overview
app.get('/api/admin/metrics', (req: Request, res: Response) => {
  const totalUsers = db.users.size;
  const totalDrivers = db.drivers.size;
  const totalRides = db.rides.size;
  const activeRides = Array.from(db.rides.values()).filter(r => r.status !== 'completed' && r.status !== 'cancelled').length;

  return res.json({
    totalUsers,
    totalDrivers,
    totalRides,
    activeRides,
    systemStatus: 'Healthy'
  });
});

// Initialize real-time components
const socketGateway = new SocketGateway(io);
socketGateway.init();

server.listen(PORT, () => {
  console.log(`TricyGo Core Backend server listening on port ${PORT}`);
});
