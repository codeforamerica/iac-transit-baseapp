const databaseService = require('./databaseService');
const logger = require('../utils/logger');

class TodoService {
  async getAllTodos() {
    try {
      logger.info('Fetching all todos');
      const todos = await databaseService.getTodos();
      logger.info(`Retrieved ${todos.length} todos`);
      return todos;
    } catch (error) {
      logger.error('Error fetching todos:', error);
      throw error;
    }
  }

  async createTodo(todoData) {
    try {
      // Validate input
      if (!todoData.text || typeof todoData.text !== 'string') {
        throw new Error('Todo text is required and must be a string');
      }

      if (todoData.text.trim().length === 0) {
        throw new Error('Todo text cannot be empty');
      }

      if (todoData.text.length > 200) {
        throw new Error('Todo text cannot exceed 200 characters');
      }

      const todo = {
        text: todoData.text.trim(),
        completed: Boolean(todoData.completed)
      };

      logger.info('Creating new todo:', { text: todo.text });
      const newTodo = await databaseService.createTodo(todo);
      logger.info('Todo created successfully:', { id: newTodo.id });
      
      return newTodo;
    } catch (error) {
      logger.error('Error creating todo:', error);
      throw error;
    }
  }

  async updateTodo(id, updates) {
    try {
      // Validate input
      if (!id) {
        throw new Error('Todo ID is required');
      }

      if (updates.text !== undefined) {
        if (typeof updates.text !== 'string') {
          throw new Error('Todo text must be a string');
        }
        if (updates.text.trim().length === 0) {
          throw new Error('Todo text cannot be empty');
        }
        if (updates.text.length > 200) {
          throw new Error('Todo text cannot exceed 200 characters');
        }
        updates.text = updates.text.trim();
      }

      if (updates.completed !== undefined) {
        updates.completed = Boolean(updates.completed);
      }

      logger.info('Updating todo:', { id, updates });
      const updatedTodo = await databaseService.updateTodo(id, updates);
      logger.info('Todo updated successfully:', { id: updatedTodo.id });
      
      return updatedTodo;
    } catch (error) {
      logger.error('Error updating todo:', error);
      throw error;
    }
  }

  async deleteTodo(id) {
    try {
      if (!id) {
        throw new Error('Todo ID is required');
      }

      logger.info('Deleting todo:', { id });
      const deletedTodo = await databaseService.deleteTodo(id);
      logger.info('Todo deleted successfully:', { id: deletedTodo.id });
      
      return deletedTodo;
    } catch (error) {
      logger.error('Error deleting todo:', error);
      throw error;
    }
  }

  async getTodoById(id) {
    try {
      if (!id) {
        throw new Error('Todo ID is required');
      }

      const todos = await databaseService.getTodos();
      const todo = todos.find(t => t.id === id);
      
      if (!todo) {
        throw new Error('Todo not found');
      }

      return todo;
    } catch (error) {
      logger.error('Error fetching todo by ID:', error);
      throw error;
    }
  }
}

module.exports = new TodoService();
