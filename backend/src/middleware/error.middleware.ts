import { Request, Response, NextFunction } from 'express';

export class AppError extends Error {
  statusCode: number;
  
  constructor(message: string, statusCode: number = 500) {
    super(message);
    this.statusCode = statusCode;
    Error.captureStackTrace(this, this.constructor);
  }
}

export const errorHandler = (
  err: any, 
  req: Request, 
  res: Response, 
  _next: NextFunction
) => {
  // Log detailed error information
  console.error('=========================================');
  console.error(`❌ Error occurred at: ${new Date().toISOString()}`);
  console.error(`📍 Path: ${req.method} ${req.path}`);
  console.error(`📝 Error Message: ${err.message}`);
  console.error(`📚 Stack Trace:`, err.stack);
  
  if (req.body && Object.keys(req.body).length > 0) {
    console.error(`📦 Request Body:`, req.body);
  }
  
  if (req.params && Object.keys(req.params).length > 0) {
    console.error(`🔑 Request Params:`, req.params);
  }
  
  console.error('=========================================');
  
  // Determine status code
  const statusCode = err.statusCode || err.status || 500;
  
  // Determine error message
  let message = err.message || 'Internal Server Error';
  
  // Handle specific error types
  if (err.name === 'ValidationError') {
    // Mongoose validation error
    const errors = Object.values(err.errors).map((e: any) => e.message);
    message = errors.join(', ');
  } else if (err.name === 'JsonWebTokenError') {
    // JWT error
    message = 'Invalid authentication token';
  } else if (err.name === 'TokenExpiredError') {
    message = 'Authentication token has expired';
  } else if (err.code === 11000) {
    // Duplicate key error
    message = 'Duplicate entry found';
  }
  
  // Send error response
  const errorResponse: any = {
    success: false,
    message: message,
    path: req.path,
    method: req.method,
    timestamp: new Date().toISOString()
  };
  
  // Add stack trace in development
  if (process.env.NODE_ENV === 'development') {
    errorResponse.stack = err.stack;
    errorResponse.statusCode = statusCode;
  }
  
  // Don't send internal error details to client in production
  if (process.env.NODE_ENV === 'production' && statusCode === 500) {
    errorResponse.message = 'Internal Server Error';
  }
  
  res.status(statusCode).json(errorResponse);
};

// Custom error classes
export class NotFoundError extends AppError {
  constructor(message: string = 'Resource not found') {
    super(message, 404);
  }
}

export class BadRequestError extends AppError {
  constructor(message: string = 'Bad request') {
    super(message, 400);
  }
}

export class UnauthorizedError extends AppError {
  constructor(message: string = 'Unauthorized') {
    super(message, 401);
  }
}

export class ForbiddenError extends AppError {
  constructor(message: string = 'Forbidden') {
    super(message, 403);
  }
}