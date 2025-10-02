const { Pool } = require('pg');
const fs = require('fs');
const path = require('path');
const logger = require('../utils/logger');
const secretsService = require('./secretsService');

class DatabaseService {
  constructor() {
    this.pool = null;
    this.dbFile = path.join(__dirname, '../../data/db.json');
    this.ensureDataDir();
  }

  ensureDataDir() {
    const dataDir = path.dirname(this.dbFile);
    if (!fs.existsSync(dataDir)) {
      fs.mkdirSync(dataDir, { recursive: true });
    }
    
    // Initialize empty database file if it doesn't exist
    if (!fs.existsSync(this.dbFile)) {
      fs.writeFileSync(this.dbFile, JSON.stringify({ todos: [] }, null, 2));
    }
  }

  async connectDatabase() {
    try {
      if (process.env.NODE_ENV === 'production' || process.env.DB_HOST !== 'localhost') {
        // Use PostgreSQL in production or when DB_HOST is set
        const config = await secretsService.getDatabaseConfig();
        
        this.pool = new Pool(config);
        
        // Test the connection
        const client = await this.pool.connect();
        await client.query('SELECT NOW()');
        client.release();
        
        logger.info('Connected to PostgreSQL database');
        
        // Initialize database schema
        await this.initializeSchema();
      } else {
        // Use JSON file for local development
        logger.info('Using JSON file database for local development');
      }
    } catch (error) {
      logger.error('Database connection failed:', error);
      throw error;
    }
  }

  async initializeSchema() {
    if (!this.pool) return;

    try {
      const createTableQuery = `
        CREATE TABLE IF NOT EXISTS todos (
          id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
          text TEXT NOT NULL,
          completed BOOLEAN DEFAULT FALSE,
          created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
          updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        );
      `;

      await this.pool.query(createTableQuery);
      logger.info('Database schema initialized');
    } catch (error) {
      logger.error('Failed to initialize database schema:', error);
      throw error;
    }
  }

  async getTodos() {
    if (this.pool) {
      // Use PostgreSQL
      const result = await this.pool.query('SELECT * FROM todos ORDER BY created_at DESC');
      return result.rows;
    } else {
      // Use JSON file
      const data = JSON.parse(fs.readFileSync(this.dbFile, 'utf8'));
      return data.todos || [];
    }
  }

  async createTodo(todo) {
    if (this.pool) {
      // Use PostgreSQL
      const result = await this.pool.query(
        'INSERT INTO todos (text, completed) VALUES ($1, $2) RETURNING *',
        [todo.text, todo.completed || false]
      );
      return result.rows[0];
    } else {
      // Use JSON file
      const data = JSON.parse(fs.readFileSync(this.dbFile, 'utf8'));
      const newTodo = {
        id: require('uuid').v4(),
        text: todo.text,
        completed: todo.completed || false,
        createdAt: new Date().toISOString(),
        updatedAt: new Date().toISOString()
      };
      
      data.todos.push(newTodo);
      fs.writeFileSync(this.dbFile, JSON.stringify(data, null, 2));
      
      return newTodo;
    }
  }

  async updateTodo(id, updates) {
    if (this.pool) {
      // Use PostgreSQL
      const setClause = [];
      const values = [];
      let paramCount = 1;

      if (updates.text !== undefined) {
        setClause.push(`text = $${paramCount++}`);
        values.push(updates.text);
      }
      if (updates.completed !== undefined) {
        setClause.push(`completed = $${paramCount++}`);
        values.push(updates.completed);
      }

      setClause.push(`updated_at = CURRENT_TIMESTAMP`);
      values.push(id);

      const result = await this.pool.query(
        `UPDATE todos SET ${setClause.join(', ')} WHERE id = $${paramCount} RETURNING *`,
        values
      );

      if (result.rows.length === 0) {
        throw new Error('Todo not found');
      }

      return result.rows[0];
    } else {
      // Use JSON file
      const data = JSON.parse(fs.readFileSync(this.dbFile, 'utf8'));
      const todoIndex = data.todos.findIndex(todo => todo.id === id);
      
      if (todoIndex === -1) {
        throw new Error('Todo not found');
      }

      data.todos[todoIndex] = {
        ...data.todos[todoIndex],
        ...updates,
        updatedAt: new Date().toISOString()
      };

      fs.writeFileSync(this.dbFile, JSON.stringify(data, null, 2));
      return data.todos[todoIndex];
    }
  }

  async deleteTodo(id) {
    if (this.pool) {
      // Use PostgreSQL
      const result = await this.pool.query('DELETE FROM todos WHERE id = $1 RETURNING *', [id]);
      
      if (result.rows.length === 0) {
        throw new Error('Todo not found');
      }

      return result.rows[0];
    } else {
      // Use JSON file
      const data = JSON.parse(fs.readFileSync(this.dbFile, 'utf8'));
      const todoIndex = data.todos.findIndex(todo => todo.id === id);
      
      if (todoIndex === -1) {
        throw new Error('Todo not found');
      }

      const deletedTodo = data.todos.splice(todoIndex, 1)[0];
      fs.writeFileSync(this.dbFile, JSON.stringify(data, null, 2));
      
      return deletedTodo;
    }
  }

  async close() {
    if (this.pool) {
      await this.pool.end();
      logger.info('Database connection closed');
    }
  }
}

module.exports = new DatabaseService();
module.exports.connectDatabase = module.exports.connectDatabase.bind(module.exports);
