import express, { Request, Response } from 'express';
import { UserController } from '../controllers/user.controller';

const router = express.Router();
const userController = new UserController();

// Get all users
router.get('/', async (req: Request, res: Response): Promise<void> => {
  await userController.getAllUsers(req, res);
});

// Get user by ID
router.get('/:id', async (req: Request, res: Response): Promise<void> => {
  await userController.getUserById(req, res);
});

// Update user
router.put('/:id', async (req: Request, res: Response): Promise<void> => {
  await userController.updateUser(req, res);
});

// Delete user
router.delete('/:id', async (req: Request, res: Response): Promise<void> => {
  await userController.deleteUser(req, res);
});

// Get user rides
router.get('/:id/rides', async (req: Request, res: Response): Promise<void> => {
  await userController.getUserRides(req, res);
});

export { router as userRouter };