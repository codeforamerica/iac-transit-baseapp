import React, { useState } from 'react';

const TodoItem = ({ todo, onUpdateTodo, onDeleteTodo, loading }) => {
  const [isEditing, setIsEditing] = useState(false);
  const [editText, setEditText] = useState(todo.text);

  const handleToggleComplete = async () => {
    try {
      await onUpdateTodo(todo.id, { ...todo, completed: !todo.completed });
    } catch (error) {
      console.error('Error updating todo:', error);
    }
  };

  const handleEdit = () => {
    setIsEditing(true);
    setEditText(todo.text);
  };

  const handleSaveEdit = async () => {
    if (!editText.trim()) return;

    try {
      await onUpdateTodo(todo.id, { ...todo, text: editText.trim() });
      setIsEditing(false);
    } catch (error) {
      console.error('Error updating todo:', error);
    }
  };

  const handleCancelEdit = () => {
    setIsEditing(false);
    setEditText(todo.text);
  };

  const handleDelete = async () => {
    if (window.confirm('Are you sure you want to delete this todo?')) {
      try {
        await onDeleteTodo(todo.id);
      } catch (error) {
        console.error('Error deleting todo:', error);
      }
    }
  };

  const handleKeyPress = (e) => {
    if (e.key === 'Enter') {
      handleSaveEdit();
    } else if (e.key === 'Escape') {
      handleCancelEdit();
    }
  };

  return (
    <div className={`todo-item ${todo.completed ? 'completed' : ''}`}>
      <div
        className={`todo-checkbox ${todo.completed ? 'checked' : ''}`}
        onClick={handleToggleComplete}
      >
        {todo.completed && '✓'}
      </div>

      {isEditing ? (
        <input
          type="text"
          value={editText}
          onChange={(e) => setEditText(e.target.value)}
          onBlur={handleSaveEdit}
          onKeyDown={handleKeyPress}
          className="todo-text"
          autoFocus
          maxLength={200}
        />
      ) : (
        <div className="todo-text" onClick={handleEdit}>
          {todo.text}
        </div>
      )}

      <div className="todo-actions">
        {!isEditing && (
          <>
            <button
              className="edit-btn"
              onClick={handleEdit}
              disabled={loading}
              title="Edit todo"
            >
              Edit
            </button>
            <button
              className="delete-btn"
              onClick={handleDelete}
              disabled={loading}
              title="Delete todo"
            >
              Delete
            </button>
          </>
        )}
      </div>
    </div>
  );
};

export default TodoItem;
