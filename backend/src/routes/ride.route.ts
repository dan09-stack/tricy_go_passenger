import express from 'express';
import { body, validationResult } from 'express-validator';
import { RideController } from '../controllers/ride.controller';

const router = express.Router();
const rideController = new RideController();

// Request a ride
router.post(
  '/request',
  [
    body('pickupLocation').isObject().withMessage('Pickup location is required'),
    body('dropoffLocation').isObject().withMessage('Dropoff location is required'),
    body('passengerCount')
      .isInt({ min: 1, max: 4 })
      .withMessage('Passenger count must be between 1 and 4'),
    body('paymentMethod')
      .isIn(['cash', 'card', 'wallet'])
      .withMessage('Invalid payment method'),
  ],
  async (req, res) => {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({ errors: errors.array() });
    }
    await rideController.requestRide(req, res);
  }
);

// Get ride details
router.get('/:rideId', async (req, res) => {
  await rideController.getRideDetails(req, res);
});

// Get ride history
router.get('/history', async (req, res) => {
  await rideController.getRideHistory(req, res);
});

// Cancel ride
router.post('/:rideId/cancel', async (req, res) => {
  await rideController.cancelRide(req, res);
});

// Rate driver
router.post(
  '/:rideId/rate',
  [
    body('rating')
      .isInt({ min: 1, max: 5 })
      .withMessage('Rating must be between 1 and 5'),
    body('review')
      .optional()
      .isString()
      .trim()
      .isLength({ max: 500 })
      .withMessage('Review must be less than 500 characters'),
  ],
  async (req, res) => {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({ errors: errors.array() });
    }
    await rideController.rateRide(req, res);
  }
);

// Get nearby drivers
router.get('/nearby-drivers', async (req, res) => {
  await rideController.getNearbyDrivers(req, res);
});

export { router as rideRouter };