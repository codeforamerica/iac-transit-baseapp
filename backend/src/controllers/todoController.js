const todoService = require('../services/todoService');
const logger = require('../utils/logger');

class TodoController {
  async getAllTodos(req, res, next) {
    try {
      const todos = await todoService.getAllTodos();
      res.json(todos);
    } catch (error) {
      next(error);
    }
  }

  async createTodo(req, res, next) {
    try {
      const todo = await todoService.createTodo(req.body);
      res.status(201).json(todo);
    } catch (error) {
      next(error);
    }
  }

  async updateTodo(req, res, next) {
    try {
      const { id } = req.params;
      const todo = await todoService.updateTodo(id, req.body);
      res.json(todo);
    } catch (error) {
      next(error);
    }
  }

  async deleteTodo(req, res, next) {
    try {
      const { id } = req.params;
      const todo = await todoService.deleteTodo(id);
      res.json(todo);
    } catch (error) {
      next(error);
    }
  }

  async getTodoById(req, res, next) {
    try {
      const { id } = req.params;
      const todo = await todoService.getTodoById(id);
      res.json(todo);
    } catch (error) {
      next(error);
    }
  }
}

module.exports = new TodoController();
