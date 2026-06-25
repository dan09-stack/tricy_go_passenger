// src/scripts/migrate-to-mongodb.ts
import { MigrationService } from '../services/migration.service';
import dotenv from 'dotenv';

dotenv.config();

const runMigration = async () => {
  const migrationService = new MigrationService();
  const mongoURI = process.env.MONGODB_URI || 'mongodb://localhost:27017/tricygo';
  
  try {
    await migrationService.migrateToMongoDB(mongoURI);
    console.log('✅ Migration completed!');
  } catch (error) {
    console.error('❌ Migration failed:', error);
    process.exit(1);
  }
};

runMigration();