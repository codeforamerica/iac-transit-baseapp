import React, { useState, useEffect } from 'react';
import { todoAPI } from './services/api';
import AddTodo from './components/AddTodo';
import TodoList from './components/TodoList';
import './index.css';

function App() {
  const [todos, setTodos] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);

  // Load todos on component mount
  useEffect(() => {
    loadTodos();
  }, []);

  const loadTodos = async () => {
    try {
      setLoading(true);
      setError(null);
      const data = await todoAPI.getTodos();
      setTodos(data);
    } catch (error) {
      console.error('Error loading todos:', error);
      setError('Failed to load todos. Please check if the backend is running.');
    } finally {
      setLoading(false);
    }
  };

  const handleAddTodo = async (text) => {
    try {
      setLoading(true);
      const newTodo = await todoAPI.createTodo({ text, completed: false });
      setTodos(prev => [...prev, newTodo]);
    } catch (error) {
      console.error('Error adding todo:', error);
      setError('Failed to add todo. Please try again.');
    } finally {
      setLoading(false);
    }
  };

  const handleUpdateTodo = async (id, updatedTodo) => {
    try {
      setLoading(true);
      const updated = await todoAPI.updateTodo(id, updatedTodo);
      setTodos(prev => prev.map(todo => todo.id === id ? updated : todo));
    } catch (error) {
      console.error('Error updating todo:', error);
      setError('Failed to update todo. Please try again.');
    } finally {
      setLoading(false);
    }
  };

  const handleDeleteTodo = async (id) => {
    try {
      setLoading(true);
      await todoAPI.deleteTodo(id);
      setTodos(prev => prev.filter(todo => todo.id !== id));
    } catch (error) {
      console.error('Error deleting todo:', error);
      setError('Failed to delete todo. Please try again.');
    } finally {
      setLoading(false);
    }
  };

  const handleRetry = () => {
    setError(null);
    loadTodos();
  };

  return (
    <div className="app">
      <div className="container">
        <header className="header">
          <h1>Todo App</h1>
          <p>IaC TRANSIT Base Application</p>
        </header>

        {error && (
          <div className="error">
            {error}
            <button onClick={handleRetry} style={{ marginLeft: '1rem', padding: '0.5rem 1rem', background: '#667eea', color: 'white', border: 'none', borderRadius: '6px', cursor: 'pointer' }}>
              Retry
            </button>
          </div>
        )}

        <AddTodo onAddTodo={handleAddTodo} loading={loading} />
        
        <TodoList
          todos={todos}
          onUpdateTodo={handleUpdateTodo}
          onDeleteTodo={handleDeleteTodo}
          loading={loading}
        />
      </div>
    </div>
  );
}

export default App;
