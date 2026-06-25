// src/db-adapter.ts
import { JsonDB } from './services/json-db.service';
import mongoose from 'mongoose';
import { ObjectId } from 'mongodb';

export interface DatabaseAdapter {
  connect(): Promise<void>;
  disconnect(): Promise<void>;
  getCollection<T>(name: string): Promise<T[]>;
  findOne<T>(collection: string, query: any): Promise<T | null>;
  findMany<T>(collection: string, query: any): Promise<T[]>;
  insertOne<T extends { id?: string }>(collection: string, data: T): Promise<T>;
  updateOne<T extends { id: string }>(collection: string, id: string, data: Partial<T>): Promise<T | null>;
  deleteOne(collection: string, id: string): Promise<boolean>;
}

// JSON Implementation
export class JsonDBAdapter implements DatabaseAdapter {
  private db: JsonDB;

  constructor() {
    this.db = new JsonDB();
  }

  async connect(): Promise<void> {
    await this.db.initialize();
  }

  async disconnect(): Promise<void> {
    // Nothing to do for JSON DB
  }

  async getCollection<T>(name: string): Promise<T[]> {
    return this.db.getCollection<T>(name);
  }

  async findOne<T>(collection: string, query: any): Promise<T | null> {
    return this.db.findOne<T>(collection, query);
  }

  async findMany<T>(collection: string, query: any): Promise<T[]> {
    return this.db.findMany<T>(collection, query);
  }

  async insertOne<T extends { id?: string }>(collection: string, data: T): Promise<T> {
    return this.db.insertOne<T>(collection, data);
  }

  async updateOne<T extends { id: string }>(collection: string, id: string, data: Partial<T>): Promise<T | null> {
    return this.db.updateOne<T>(collection, id, data);
  }

  async deleteOne(collection: string, id: string): Promise<boolean> {
    return this.db.deleteOne(collection, id);
  }
}

// MongoDB Implementation
export class MongoDBAdapter implements DatabaseAdapter {
  private isConnected: boolean = false;

  constructor() {}

  async connect(): Promise<void> {
    if (this.isConnected) {
      console.log('✅ Using existing MongoDB connection');
      return;
    }

    const mongoURI = process.env.MONGODB_URI || 'mongodb://localhost:27017/tricygo';
    
    try {
      await mongoose.connect(mongoURI);
      this.isConnected = true;
      console.log('✅ MongoDB connected successfully');
      
      mongoose.connection.on('error', (error) => {
        console.error('MongoDB connection error:', error);
        this.isConnected = false;
      });

      mongoose.connection.on('disconnected', () => {
        console.log('MongoDB disconnected');
        this.isConnected = false;
      });
    } catch (error) {
      console.error('❌ MongoDB connection failed:', error);
      throw error;
    }
  }

  async disconnect(): Promise<void> {
    if (!this.isConnected) return;
    
    try {
      await mongoose.disconnect();
      this.isConnected = false;
      console.log('MongoDB disconnected successfully');
    } catch (error) {
      console.error('Error disconnecting from MongoDB:', error);
    }
  }

  async getCollection<T>(name: string): Promise<T[]> {
    const collection = mongoose.connection.collection(name);
    return collection.find({}).toArray() as Promise<T[]>;
  }

  async findOne<T>(collection: string, query: any): Promise<T | null> {
    const coll = mongoose.connection.collection(collection);
    return coll.findOne(query) as Promise<T | null>;
  }

  async findMany<T>(collection: string, query: any): Promise<T[]> {
    const coll = mongoose.connection.collection(collection);
    return coll.find(query).toArray() as Promise<T[]>;
  }

  async insertOne<T extends { id?: string }>(collection: string, data: T): Promise<T> {
    const coll = mongoose.connection.collection(collection);
    // Remove id if present (MongoDB uses _id)
    const { id, ...rest } = data as any;
    const result = await coll.insertOne(rest);
    // Return the original data with the MongoDB _id
    return { ...data, _id: result.insertedId } as T;
  }

  async updateOne<T extends { id: string }>(collection: string, id: string, data: Partial<T>): Promise<T | null> {
    const coll = mongoose.connection.collection(collection);
    const result = await coll.findOneAndUpdate(
      { _id: new ObjectId(id) },
      { $set: { ...data, updatedAt: new Date().toISOString() } },
      { returnDocument: 'after' }
    );
    
    // Check if result has a value property (MongoDB driver v4+)
    if (result && 'value' in result) {
      return result.value as T | null;
    }
    
    // For older versions or different return types
    return result as unknown as T | null;
  }

  async deleteOne(collection: string, id: string): Promise<boolean> {
    const coll = mongoose.connection.collection(collection);
    const result = await coll.deleteOne({ _id: new ObjectId(id) });
    return result.deletedCount === 1;
  }
}

// Factory to create adapter based on environment
export function createDatabaseAdapter(): DatabaseAdapter {
  const useMongoDB = process.env.USE_MONGODB === 'true';
  
  if (useMongoDB) {
    console.log('📦 Using MongoDB adapter');
    return new MongoDBAdapter();
  } else {
    console.log('📦 Using JSON file adapter');
    return new JsonDBAdapter();
  }
}