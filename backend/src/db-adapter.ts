import { JsonDB } from './services/json-db.service';
import mongoose from 'mongoose';
import { ObjectId } from 'mongodb';

export interface DatabaseAdapter {
  connect(): Promise<void>;
  disconnect(): Promise<void>;
  getCollection<T>(name: string): Promise<T[]>;
  findOne<T>(collection: string, query: any): Promise<T | null>;
  findMany<T>(collection: string, query: any): Promise<T[]>;
  insertOne<T>(collection: string, data: any): Promise<T>;  // Removed constraint
  updateOne<T>(collection: string, id: string, data: Partial<T>): Promise<T | null>;
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
    console.log('✅ JSON Database connected');
  }

  async disconnect(): Promise<void> {
    console.log('✅ JSON Database disconnected');
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

  async insertOne<T>(collection: string, data: any): Promise<T> {
    console.log(`📝 Inserting into ${collection}:`, data);
    const result = await this.db.insertOne(collection, data);
    console.log(`✅ Inserted into ${collection}:`, result);
    return result as T;
  }

  async updateOne<T>(collection: string, id: string, data: Partial<T>): Promise<T | null> {
    return this.db.updateOne(collection, id, data);
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

  async insertOne<T>(collection: string, data: any): Promise<T> {
    const coll = mongoose.connection.collection(collection);
    const result = await coll.insertOne(data);
    return { ...data, _id: result.insertedId } as T;
  }

  async updateOne<T>(collection: string, id: string, data: Partial<T>): Promise<T | null> {
    const coll = mongoose.connection.collection(collection);
    const result = await coll.findOneAndUpdate(
      { _id: new ObjectId(id) },
      { $set: { ...data, updatedAt: new Date().toISOString() } },
      { returnDocument: 'after' }
    );
    
    if (result && 'value' in result) {
      return result.value as T | null;
    }
    
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
  
  console.log(`🔍 USE_MONGODB = "${process.env.USE_MONGODB}"`);
  console.log(`📦 Using ${useMongoDB ? 'MongoDB' : 'JSON'} adapter`);
  
  if (useMongoDB) {
    return new MongoDBAdapter();
  } else {
    return new JsonDBAdapter();
  }
}