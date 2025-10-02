# API Documentation

## Overview

The Todo App API provides RESTful endpoints for managing todos. The API is built with Node.js and Express.js, following REST conventions and returning JSON responses.

## Base URL

- **Local Development**: `http://localhost:3001/api`
- **Production**: `https://your-domain.com/api`

## Authentication

Currently, the API does not require authentication. In a production environment, you should implement proper authentication and authorization.

## Response Format

All API responses follow a consistent format:

### Success Response
```json
{
  "id": "uuid",
  "text": "Todo item text",
  "completed": false,
  "createdAt": "2024-01-01T00:00:00.000Z",
  "updatedAt": "2024-01-01T00:00:00.000Z"
}
```

### Error Response
```json
{
  "error": {
    "message": "Error description",
    "status": 400,
    "timestamp": "2024-01-01T00:00:00.000Z",
    "path": "/api/todos",
    "method": "GET"
  }
}
```

## Endpoints

### Health Check

#### GET /api/health

Check the health status of the API.

**Response:**
```json
{
  "status": "healthy",
  "timestamp": "2024-01-01T00:00:00.000Z",
  "uptime": 3600,
  "environment": "development"
}
```

---

### Todos

#### GET /api/todos

Retrieve all todos.

**Response:**
```json
[
  {
    "id": "123e4567-e89b-12d3-a456-426614174000",
    "text": "Complete project documentation",
    "completed": false,
    "createdAt": "2024-01-01T00:00:00.000Z",
    "updatedAt": "2024-01-01T00:00:00.000Z"
  },
  {
    "id": "123e4567-e89b-12d3-a456-426614174001",
    "text": "Review code changes",
    "completed": true,
    "createdAt": "2024-01-01T01:00:00.000Z",
    "updatedAt": "2024-01-01T02:00:00.000Z"
  }
]
```

#### POST /api/todos

Create a new todo.

**Request Body:**
```json
{
  "text": "New todo item",
  "completed": false
}
```

**Response:**
```json
{
  "id": "123e4567-e89b-12d3-a456-426614174002",
  "text": "New todo item",
  "completed": false,
  "createdAt": "2024-01-01T03:00:00.000Z",
  "updatedAt": "2024-01-01T03:00:00.000Z"
}
```

**Validation:**
- `text` is required and must be a non-empty string
- `text` cannot exceed 200 characters
- `completed` is optional and defaults to `false`

#### GET /api/todos/:id

Retrieve a specific todo by ID.

**Parameters:**
- `id` (string): The UUID of the todo

**Response:**
```json
{
  "id": "123e4567-e89b-12d3-a456-426614174000",
  "text": "Complete project documentation",
  "completed": false,
  "createdAt": "2024-01-01T00:00:00.000Z",
  "updatedAt": "2024-01-01T00:00:00.000Z"
}
```

**Error Responses:**
- `404 Not Found`: Todo with the specified ID does not exist

#### PUT /api/todos/:id

Update an existing todo.

**Parameters:**
- `id` (string): The UUID of the todo

**Request Body:**
```json
{
  "text": "Updated todo item",
  "completed": true
}
```

**Response:**
```json
{
  "id": "123e4567-e89b-12d3-a456-426614174000",
  "text": "Updated todo item",
  "completed": true,
  "createdAt": "2024-01-01T00:00:00.000Z",
  "updatedAt": "2024-01-01T04:00:00.000Z"
}
```

**Validation:**
- `text` is optional but must be a non-empty string if provided
- `text` cannot exceed 200 characters
- `completed` is optional

**Error Responses:**
- `404 Not Found`: Todo with the specified ID does not exist

#### DELETE /api/todos/:id

Delete a todo.

**Parameters:**
- `id` (string): The UUID of the todo

**Response:**
```json
{
  "id": "123e4567-e89b-12d3-a456-426614174000",
  "text": "Deleted todo item",
  "completed": false,
  "createdAt": "2024-01-01T00:00:00.000Z",
  "updatedAt": "2024-01-01T00:00:00.000Z"
}
```

**Error Responses:**
- `404 Not Found`: Todo with the specified ID does not exist

## Error Codes

| Status Code | Description |
|-------------|-------------|
| 200 | Success |
| 201 | Created |
| 400 | Bad Request - Invalid input data |
| 404 | Not Found - Resource does not exist |
| 500 | Internal Server Error |

## Rate Limiting

Currently, there is no rate limiting implemented. In a production environment, you should implement rate limiting to prevent abuse.

## CORS

The API supports Cross-Origin Resource Sharing (CORS) for the following origins:
- `http://localhost:3000` (local development)
- `http://frontend:3000` (Docker environment)
- Production domain (configured via environment variable)

## Logging

All API requests are logged with the following information:
- Timestamp
- HTTP method and path
- Client IP address
- User agent
- Response status code
- Processing time

## Environment Variables

The API uses the following environment variables:

### Required
- `API_PORT`: Port number for the API server (default: 3001)
- `NODE_ENV`: Environment (development, production)

### Database (Local Development)
- `DB_HOST`: Database host (default: localhost)
- `DB_PORT`: Database port (default: 5432)
- `DB_NAME`: Database name (default: todoapp)
- `DB_USER`: Database username (default: todoapp_user)
- `DB_PASSWORD`: Database password

### AWS (Production)
- `AWS_REGION`: AWS region (default: us-east-1)
- `SECRETS_MANAGER_SECRET_NAME`: Secrets Manager secret name (default: todoapp-secrets)

## Examples

### Using cURL

#### Get all todos
```bash
curl -X GET http://localhost:3001/api/todos
```

#### Create a new todo
```bash
curl -X POST http://localhost:3001/api/todos \
  -H "Content-Type: application/json" \
  -d '{"text": "Learn about APIs", "completed": false}'
```

#### Update a todo
```bash
curl -X PUT http://localhost:3001/api/todos/123e4567-e89b-12d3-a456-426614174000 \
  -H "Content-Type: application/json" \
  -d '{"completed": true}'
```

#### Delete a todo
```bash
curl -X DELETE http://localhost:3001/api/todos/123e4567-e89b-12d3-a456-426614174000
```

### Using JavaScript (Fetch API)

#### Get all todos
```javascript
const response = await fetch('http://localhost:3001/api/todos');
const todos = await response.json();
console.log(todos);
```

#### Create a new todo
```javascript
const response = await fetch('http://localhost:3001/api/todos', {
  method: 'POST',
  headers: {
    'Content-Type': 'application/json',
  },
  body: JSON.stringify({
    text: 'Learn about APIs',
    completed: false
  })
});
const newTodo = await response.json();
console.log(newTodo);
```

## Testing

The API can be tested using various tools:

1. **Postman**: Import the API endpoints and test manually
2. **curl**: Use the command-line examples above
3. **JavaScript**: Use the Fetch API examples
4. **Automated Testing**: Implement unit and integration tests

## Monitoring

The API includes health check endpoints and comprehensive logging for monitoring:

- Health check: `GET /api/health`
- Logs are written to CloudWatch in production
- Local logs are written to the `logs/` directory
