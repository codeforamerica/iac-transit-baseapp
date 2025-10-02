const express = require('express');
const todoController = require('../controllers/todoController');
const logger = require('../utils/logger');

const router = express.Router();

// Middleware to log all todo requests
router.use((req, res, next) => {
  logger.info(`Todo API: ${req.method} ${req.path}`, {
    ip: req.ip,
    userAgent: req.get('User-Agent')
  });
  next();
});

// GET /api/todos - Get all todos
router.get('/', todoController.getAllTodos);

// POST /api/todos - Create a new todo
router.post('/', todoController.createTodo);

// GET /api/todos/:id - Get a specific todo
router.get('/:id', todoController.getTodoById);

// PUT /api/todos/:id - Update a todo
router.put('/:id', todoController.updateTodo);

// DELETE /api/todos/:id - Delete a todo
router.delete('/:id', todoController.deleteTodo);

module.exports = router;
