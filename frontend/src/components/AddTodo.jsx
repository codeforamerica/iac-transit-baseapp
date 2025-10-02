import React, { useState } from 'react';

const AddTodo = ({ onAddTodo, loading }) => {
  const [text, setText] = useState('');

  const handleSubmit = async (e) => {
    e.preventDefault();
    if (!text.trim()) return;

    try {
      await onAddTodo(text.trim());
      setText('');
    } catch (error) {
      console.error('Error adding todo:', error);
    }
  };

  return (
    <form onSubmit={handleSubmit} className="add-todo">
      <input
        type="text"
        value={text}
        onChange={(e) => setText(e.target.value)}
        placeholder="What needs to be done?"
        disabled={loading}
        maxLength={200}
      />
      <button type="submit" disabled={loading || !text.trim()}>
        {loading ? 'Adding...' : 'Add Todo'}
      </button>
    </form>
  );
};

export default AddTodo;
