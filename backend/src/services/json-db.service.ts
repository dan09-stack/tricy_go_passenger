// src/services/json-db.service.ts
import fs from 'fs/promises';
import path from 'path';
import { v4 as uuidv4 } from 'uuid'; 

export interface JsonDBOptions {
  filePath?: string;
  pretty?: boolean;
  indent?: number;
}

export class JsonDB {
  private data: any = {};
  private filePath: string;
  private pretty: boolean;
  private indent: number;
  private initialized: boolean = false;

  constructor(options: JsonDBOptions = {}) {
    this.filePath = options.filePath || path.join(__dirname, '../../data/db.json');
    this.pretty = options.pretty ?? true;
    this.indent = options.indent ?? 2;
  }

  async initialize(): Promise<void> {
    try {
      // Ensure directory exists
      const dir = path.dirname(this.filePath);
      await fs.mkdir(dir, { recursive: true });
      
      // Try to read existing file
      try {
        const fileContent = await fs.readFile(this.filePath, 'utf-8');
        this.data = JSON.parse(fileContent);
        console.log(`✅ JSON DB loaded from: ${this.filePath}`);
      } catch (error: any) {
        if (error.code === 'ENOENT') {
          // File doesn't exist, create with empty structure
          this.data = this.getDefaultStructure();
          await this.save();
          console.log(`✅ JSON DB created at: ${this.filePath}`);
        } else {
          throw error;
        }
      }
      
      this.initialized = true;
    } catch (error) {
      console.error('❌ Failed to initialize JSON DB:', error);
      throw error;
    }
  }

  private getDefaultStructure(): any {
    return {
      users: [],
      rides: [],
      drivers: [],
      otps: [],
      _meta: {
        created: new Date().toISOString(),
        version: '1.0.0'
      }
    };
  }

  private async save(): Promise<void> {
    try {
      const content = this.pretty 
        ? JSON.stringify(this.data, null, this.indent)
        : JSON.stringify(this.data);
      
      await fs.writeFile(this.filePath, content, 'utf-8');
    } catch (error) {
      console.error('❌ Failed to save JSON DB:', error);
      throw error;
    }
  }

  // Collection methods
  async getCollection<T>(name: string): Promise<T[]> {
    if (!this.initialized) await this.initialize();
    return this.data[name] || [];
  }

  async findOne<T>(collection: string, query: Partial<T>): Promise<T | null> {
    const items = await this.getCollection<T>(collection);
    return items.find(item => 
      Object.keys(query).every(key => 
        (item as any)[key] === (query as any)[key]
      )
    ) || null;
  }

  async findMany<T>(collection: string, query?: Partial<T>): Promise<T[]> {
    const items = await this.getCollection<T>(collection);
    if (!query) return items;
    
    return items.filter(item =>
      Object.keys(query).every(key =>
        (item as any)[key] === (query as any)[key]
      )
    );
  }

  async insertOne<T extends { id?: string }>(collection: string, item: T): Promise<T> {
    if (!this.initialized) await this.initialize();
    
    if (!this.data[collection]) {
      this.data[collection] = [];
    }
    
    // Add ID if not present
    if (!item.id) {
      item.id = uuidv4();
    }
    
    // Add timestamps
    const newItem = {
      ...item,
      createdAt: new Date().toISOString(),
      updatedAt: new Date().toISOString()
    };
    
    this.data[collection].push(newItem);
    await this.save();
    return newItem as T;
  }

  async updateOne<T extends { id: string }>(collection: string, id: string, updates: Partial<T>): Promise<T | null> {
    const items = await this.getCollection<T>(collection);
    const index = items.findIndex(item => (item as any).id === id);
    
    if (index === -1) return null;
    
    const updated = {
      ...items[index],
      ...updates,
      updatedAt: new Date().toISOString()
    };
    
    this.data[collection][index] = updated;
    await this.save();
    return updated;
  }

  async deleteOne(collection: string, id: string): Promise<boolean> {
    const items = await this.getCollection(collection);
    const index = items.findIndex((item: any) => item.id === id);
    
    if (index === -1) return false;
    
    this.data[collection].splice(index, 1);
    await this.save();
    return true;
  }

  async clearCollection(collection: string): Promise<void> {
    this.data[collection] = [];
    await this.save();
  }

  async dropAll(): Promise<void> {
    this.data = this.getDefaultStructure();
    await this.save();
  }

  // Migration helper
  exportToJSON(): string {
    return JSON.stringify(this.data, null, this.indent);
  }

  async importFromJSON(jsonData: string): Promise<void> {
    try {
      this.data = JSON.parse(jsonData);
      await this.save();
      console.log('✅ Data imported successfully');
    } catch (error) {
      console.error('❌ Failed to import JSON:', error);
      throw error;
    }
  }
}