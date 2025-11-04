import axios from 'axios';

let API_URL = '/api'; // Default to relative path for local dev

// Try to load from runtime config if available
async function initializeAPI() {
  try {
    const response = await fetch('/config.json');
    if (response.ok) {
      const config = await response.json();
      API_URL = config.apiUrl || '/api';
    }
  } catch (e) {
    // Silently fail and use default
    console.log('Using default API URL:', API_URL);
  }
}

// Initialize on module load
initializeAPI();

export function getAPIUrl() {
  return API_URL;
}

export async function fetchTodos() {
  const response = await fetch(`${API_URL}/todos`);
  if (!response.ok) throw new Error('Failed to fetch todos');
  return response.json();
}

export async function addTodo(text) {
  const response = await fetch(`${API_URL}/todos`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ text })
  });
  if (!response.ok) throw new Error('Failed to add todo');
  return response.json();
}

export async function updateTodo(id, updates) {
  const response = await fetch(`${API_URL}/todos/${id}`, {
    method: 'PUT',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify(updates)
  });
  if (!response.ok) throw new Error('Failed to update todo');
  return response.json();
}

export async function deleteTodo(id) {
  const response = await fetch(`${API_URL}/todos/${id}`, {
    method: 'DELETE'
  });
  if (!response.ok) throw new Error('Failed to delete todo');
  return response.json();
}
