// src/services/migration.service.ts
import mongoose from 'mongoose';
import { JsonDB } from './json-db.service';

export class MigrationService {
  private jsonDB: JsonDB;

  constructor() {
    this.jsonDB = new JsonDB();
  }

  async migrateToMongoDB(mongoURI: string): Promise<void> {
    try {
      console.log('🔄 Starting migration to MongoDB...');
      
      // Initialize JSON DB
      await this.jsonDB.initialize();
      
      // Connect to MongoDB
      await mongoose.connect(mongoURI);
      console.log('✅ Connected to MongoDB');
      
      // Get all collections from JSON DB
      const data = (this.jsonDB as any).data;
      const collections = Object.keys(data).filter(key => !key.startsWith('_'));
      
      for (const collectionName of collections) {
        console.log(`📦 Migrating collection: ${collectionName}`);
        const items = data[collectionName];
        
        if (!items || items.length === 0) {
          console.log(`  ⚠️ No items in ${collectionName}, skipping`);
          continue;
        }
        
        // Create model dynamically
        const collection = mongoose.connection.collection(collectionName);
        
        // Clear existing data
        await collection.deleteMany({});
        console.log(`  🗑️ Cleared existing data in ${collectionName}`);
        
        // Insert new data
        await collection.insertMany(items);
        console.log(`  ✅ Migrated ${items.length} items to ${collectionName}`);
      }
      
      console.log('✅ Migration completed successfully!');
    } catch (error) {
      console.error('❌ Migration failed:', error);
      throw error;
    } finally {
      await mongoose.disconnect();
    }
  }
}