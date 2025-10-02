#!/bin/bash

# Setup script for local development
set -e

echo "🚀 Setting up Todo App for local development..."

# Check if Docker is running
if ! docker info > /dev/null 2>&1; then
    echo "❌ Docker is not running. Please start Docker and try again."
    exit 1
fi

# Check if Docker Compose is available
if ! command -v docker-compose &> /dev/null; then
    echo "❌ Docker Compose is not installed. Please install Docker Compose and try again."
    exit 1
fi

# Create .env file if it doesn't exist
if [ ! -f .env ]; then
    echo "📝 Creating .env file from .env.example..."
    cp .env.example .env
    echo "✅ .env file created. Please review and update as needed."
else
    echo "✅ .env file already exists."
fi

# Create .env.local file if it doesn't exist (for sensitive variables)
if [ ! -f .env.local ]; then
    echo "📝 Creating .env.local file for sensitive variables..."
    cat > .env.local << EOF
# Sensitive environment variables for local development
# This file is gitignored and should not be committed

# Database Configuration
DB_HOST=localhost
DB_PORT=5432
DB_NAME=todoapp
DB_USER=todoapp_user
DB_PASSWORD=todoapp_password
EOF
    echo "✅ .env.local file created with default values."
    echo "⚠️  Please update the database password in .env.local for security."
else
    echo "✅ .env.local file already exists."
fi

# Build and start the application
echo "🔨 Building and starting the application..."
docker-compose up --build -d

# Wait for services to be ready
echo "⏳ Waiting for services to be ready..."
sleep 10

# Check if services are running
if docker-compose ps | grep -q "Up"; then
    echo "✅ Application is running!"
    echo ""
    echo "🌐 Frontend: http://localhost:3000"
    echo "🔧 Backend API: http://localhost:3001"
    echo "🗄️  Database: localhost:5432"
    echo ""
    echo "📊 To view logs: docker-compose logs -f"
    echo "🛑 To stop: docker-compose down"
else
    echo "❌ Failed to start the application. Check the logs with: docker-compose logs"
    exit 1
fi

echo "🎉 Setup complete! Happy coding!"
