// src/config/env.config.ts
export class EnvConfig {
  static isDevelopment(): boolean {
    return process.env.NODE_ENV === 'development';
  }
  
  static isTest(): boolean {
    return process.env.NODE_ENV === 'test';
  }
  
  static isProduction(): boolean {
    return process.env.NODE_ENV === 'production';
  }
  
  static isDevMode(): boolean {
    return this.isDevelopment() || this.isTest();
  }
  
  static getDevOTP(): string | undefined {
    // Only return dev OTP in non-production
    if (this.isDevMode()) {
      return process.env.DEV_OTP || '123456';
    }
    return undefined;
  }
  
  static shouldBypassOTP(): boolean {
    // Only bypass in development with explicit flag
    return this.isDevMode() && process.env.ENABLE_DEV_BYPASS === 'true';
  }
}