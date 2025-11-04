import axios from 'axios';

let API_BASE_URL = 'http://localhost:3001';

// Load config immediately and wait for it
const configPromise = (async () => {
  try {
    const response = await fetch('/config.json');
    if (response.ok) {
      const config = await response.json();
      API_BASE_URL = config.apiUrl || 'http://localhost:3001';
      console.log('Loaded API URL from config:', API_BASE_URL);
    }
  } catch (e) {
    console.log('Using default API URL:', API_BASE_URL);
  }
})();

export const todoAPI = {
  // Get all todos
  getTodos: async () => {
    await configPromise;
    const response = await fetch(`${API_BASE_URL}/api/todos`);
    if (!response.ok) throw new Error('Failed to fetch todos');
    return response.json();
  },

  // Create a new todo
  createTodo: async (todo) => {
    await configPromise;
    const response = await fetch(`${API_BASE_URL}/api/todos`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(todo)
    });
    if (!response.ok) throw new Error('Failed to create todo');
    return response.json();
  },

  // Update a todo
  updateTodo: async (id, todo) => {
    await configPromise;
    const response = await fetch(`${API_BASE_URL}/api/todos/${id}`, {
      method: 'PUT',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(todo)
    });
    if (!response.ok) throw new Error('Failed to update todo');
    return response.json();
  },

  // Delete a todo
  deleteTodo: async (id) => {
    await configPromise;
    const response = await fetch(`${API_BASE_URL}/api/todos/${id}`, {
      method: 'DELETE'
    });
    if (!response.ok) throw new Error('Failed to delete todo');
    return response.json();
  },

  // Health check
  healthCheck: async () => {
    await configPromise;
    const response = await fetch(`${API_BASE_URL}/api/health`);
    if (!response.ok) throw new Error('Failed to health check');
    return response.json();
  },
};

export default todoAPI;
