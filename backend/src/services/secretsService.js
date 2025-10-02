const AWS = require('aws-sdk');
const logger = require('../utils/logger');

class SecretsService {
  constructor() {
    this.secretsManager = new AWS.SecretsManager({
      region: process.env.AWS_REGION || 'us-east-1'
    });
    this.secretName = process.env.SECRETS_MANAGER_SECRET_NAME || 'todoapp-secrets';
    this.cachedSecrets = null;
    this.cacheExpiry = null;
    this.cacheDuration = 5 * 60 * 1000; // 5 minutes
  }

  async getSecrets() {
    // Return cached secrets if still valid
    if (this.cachedSecrets && this.cacheExpiry && Date.now() < this.cacheExpiry) {
      return this.cachedSecrets;
    }

    try {
      // Check if we're in a cloud environment
      if (process.env.NODE_ENV === 'production' && process.env.AWS_REGION) {
        logger.info('Fetching secrets from AWS Secrets Manager');
        
        const result = await this.secretsManager.getSecretValue({
          SecretId: this.secretName
        }).promise();

        const secrets = JSON.parse(result.SecretString);
        
        // Cache the secrets
        this.cachedSecrets = secrets;
        this.cacheExpiry = Date.now() + this.cacheDuration;
        
        logger.info('Successfully retrieved secrets from AWS Secrets Manager');
        return secrets;
      } else {
        // Local development - use environment variables
        logger.info('Using environment variables for local development');
        
        const secrets = {
          db_host: process.env.DB_HOST || 'localhost',
          db_port: process.env.DB_PORT || '5432',
          db_name: process.env.DB_NAME || 'todoapp',
          db_user: process.env.DB_USER || 'todoapp_user',
          db_password: process.env.DB_PASSWORD || 'todoapp_password'
        };

        this.cachedSecrets = secrets;
        this.cacheExpiry = Date.now() + this.cacheDuration;
        
        return secrets;
      }
    } catch (error) {
      logger.error('Failed to retrieve secrets:', error);
      
      // Fallback to environment variables
      logger.warn('Falling back to environment variables');
      
      const fallbackSecrets = {
        db_host: process.env.DB_HOST || 'localhost',
        db_port: process.env.DB_PORT || '5432',
        db_name: process.env.DB_NAME || 'todoapp',
        db_user: process.env.DB_USER || 'todoapp_user',
        db_password: process.env.DB_PASSWORD || 'todoapp_password'
      };

      this.cachedSecrets = fallbackSecrets;
      this.cacheExpiry = Date.now() + this.cacheDuration;
      
      return fallbackSecrets;
    }
  }

  async getDatabaseConfig() {
    const secrets = await this.getSecrets();
    
    return {
      host: secrets.db_host,
      port: parseInt(secrets.db_port),
      database: secrets.db_name,
      user: secrets.db_user,
      password: secrets.db_password,
      ssl: process.env.NODE_ENV === 'production' ? { rejectUnauthorized: false } : false
    };
  }

  // Clear cache (useful for testing)
  clearCache() {
    this.cachedSecrets = null;
    this.cacheExpiry = null;
  }
}

module.exports = new SecretsService();
