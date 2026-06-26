// src/middleware/dev.middleware.ts
import { Request, Response, NextFunction } from 'express';
import { EnvConfig } from '../config/env.config';

export const devOnly = (req: Request, res: Response, next: NextFunction) => {
  if (!EnvConfig.isDevMode()) {
    res.status(403).json({
      success: false,
      message: 'This endpoint is only available in development'
    });
    return;
  }
  next();
};

export const requireDevFeature = (feature: string) => {
  return (req: Request, res: Response, next: NextFunction) => {
    if (!EnvConfig.isDevMode()) {
      res.status(403).json({
        success: false,
        message: 'Development features not available'
      });
      return;
    }
    
    if (process.env[feature] !== 'true') {
      res.status(403).json({
        success: false,
        message: `${feature} is not enabled`
      });
      return;
    }
    
    next();
  };
};