// src/services/audit.service.ts
import fs from 'fs/promises';
import path from 'path';

export class AuditService {
  private logPath: string;

  constructor() {
    this.logPath = path.join(process.cwd(), 'logs/audit.json');
  }

  async logDevBypass(data: {
    phoneNumber: string;
    ip: string;
    method: string;
    timestamp: string;
  }): Promise<void> {
    // Only log in development
    if (process.env.NODE_ENV !== 'development') return;
    
    const logEntry = {
      ...data,
      type: 'DEV_BYPASS',
      environment: process.env.NODE_ENV,
      userAgent: data
    };
    
    try {
      // Append to log file
      const logs = await this.readLogs();
      logs.push(logEntry);
      await fs.writeFile(this.logPath, JSON.stringify(logs, null, 2));
    } catch (error) {
      console.error('Failed to write audit log:', error);
    }
  }

  private async readLogs(): Promise<any[]> {
    try {
      const content = await fs.readFile(this.logPath, 'utf-8');
      return JSON.parse(content);
    } catch {
      return [];
    }
  }
}