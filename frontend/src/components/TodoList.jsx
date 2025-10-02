import React from 'react';
import TodoItem from './TodoItem';

const TodoList = ({ todos, onUpdateTodo, onDeleteTodo, loading }) => {
  if (loading) {
    return (
      <div className="loading">
        Loading todos...
      </div>
    );
  }

  if (!todos || todos.length === 0) {
    return (
      <div className="empty-state">
        <h3>No todos yet</h3>
        <p>Add your first todo above to get started!</p>
      </div>
    );
  }

  return (
    <div className="todo-list">
      {todos.map((todo) => (
        <TodoItem
          key={todo.id}
          todo={todo}
          onUpdateTodo={onUpdateTodo}
          onDeleteTodo={onDeleteTodo}
          loading={loading}
        />
      ))}
    </div>
  );
};

export default TodoList;
