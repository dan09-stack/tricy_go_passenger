// src/index.ts
import express, { Request, Response } from 'express';
import cors from 'cors';
import helmet from 'helmet';
import rateLimit from 'express-rate-limit';
import dotenv from 'dotenv';
import { createServer } from 'http';
import { Server as SocketServer } from 'socket.io';
import { createDatabaseAdapter } from './db-adapter';
import { authMiddleware } from './middleware/auth.middleware';
import { SocketService } from './services/socket.service';
import { authRouter } from './routes/auth.route';
import { rideRouter } from './routes/ride.route';
import { errorHandler } from './middleware/error.middleware';
import { userRouter } from './routes/user.route';

dotenv.config();

const app = express();
const server = createServer(app);
const io = new SocketServer(server, {
  cors: {
    origin: process.env.CLIENT_URL || 'http://localhost:3000',
    methods: ['GET', 'POST'],
    credentials: true,
  },
});

// Rate limiting
const limiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 100, // Limit each IP to 100 requests per windowMs
  message: 'Too many requests from this IP, please try again later.',
});

// Middleware
app.use(helmet());
app.use(cors({
  origin: process.env.CLIENT_URL || 'http://localhost:3000',
  credentials: true,
}));
app.use(express.json());
app.use(express.urlencoded({ extended: true }));
app.use('/api', limiter);

// Socket.io service
const socketService = new SocketService(io);
socketService.initialize();

// Database adapter
const dbAdapter = createDatabaseAdapter();

// Routes
app.use('/api/auth', authRouter);
app.use('/api/rides', authMiddleware, rideRouter);
app.use('/api/users', authMiddleware, userRouter);

// Health check
app.get('/health', (_req: Request, res: Response) => {
  res.json({ 
    status: 'OK', 
    timestamp: new Date().toISOString(),
    environment: process.env.NODE_ENV,
    database: process.env.USE_MONGODB === 'true' ? 'MongoDB' : 'JSON File'
  });
});

// Error handler
app.use(errorHandler);

// Connect to database and start server
const startServer = async () => {
  try {
    await dbAdapter.connect();
    
    const PORT = process.env.PORT || 3000;
    server.listen(PORT, () => {
      console.log(`🚀 Server running on port ${PORT}`);
      console.log(`📡 Environment: ${process.env.NODE_ENV}`);
      console.log(`📦 Database: ${process.env.USE_MONGODB === 'true' ? 'MongoDB' : 'JSON File'}`);
      console.log(`🔄 Socket.io enabled`);
    });
  } catch (error) {
    console.error('Failed to start server:', error);
    process.exit(1);
  }
};

startServer();

export { app, server, io };