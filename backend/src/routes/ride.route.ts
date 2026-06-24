import express, { Request, Response } from 'express';
import { body, validationResult, ValidationChain } from 'express-validator';
import { RideController } from '../controllers/ride.controller';

const router = express.Router();
const rideController = new RideController();

// Wrapper for validation
const validate = (validations: ValidationChain[]) => {
  return async (req: Request, res: Response, next: any) => {
    await Promise.all(validations.map(validation => validation.run(req)));
    
    const errors = validationResult(req);
    if (errors.isEmpty()) {
      return next();
    }
    
    res.status(400).json({ errors: errors.array() });
  };
};

// Wrapper for async controller methods
const asyncHandler = (fn: (req: Request, res: Response) => Promise<void>) => {
  return async (req: Request, res: Response): Promise<void> => {
    try {
      await fn(req, res);
    } catch (error: any) {
      res.status(500).json({
        success: false,
        message: 'Internal server error',
        error: error.message
      });
    }
  };
};

// Request a ride
router.post(
  '/request',
  validate([
    body('pickupLocation').isObject().withMessage('Pickup location is required'),
    body('dropoffLocation').isObject().withMessage('Dropoff location is required'),
    body('passengerCount')
      .isInt({ min: 1, max: 4 })
      .withMessage('Passenger count must be between 1 and 4'),
    body('paymentMethod')
      .isIn(['cash', 'card', 'wallet'])
      .withMessage('Invalid payment method'),
  ]),
  asyncHandler(rideController.requestRide.bind(rideController))
);

// Get ride details
router.get('/:rideId', asyncHandler(rideController.getRideDetails.bind(rideController)));

// Get ride history
router.get('/history', asyncHandler(rideController.getRideHistory.bind(rideController)));

// Cancel ride
router.post('/:rideId/cancel', asyncHandler(rideController.cancelRide.bind(rideController)));

// Rate driver
router.post(
  '/:rideId/rate',
  validate([
    body('rating')
      .isInt({ min: 1, max: 5 })
      .withMessage('Rating must be between 1 and 5'),
    body('review')
      .optional()
      .isString()
      .trim()
      .isLength({ max: 500 })
      .withMessage('Review must be less than 500 characters'),
  ]),
  asyncHandler(rideController.rateRide.bind(rideController))
);

// Get nearby drivers
router.get('/nearby-drivers', asyncHandler(rideController.getNearbyDrivers.bind(rideController)));

export { router as rideRouter };