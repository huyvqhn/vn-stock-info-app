#!/bin/bash

# Deploy script for LightNode instance
set -e

echo "🚀 Starting deployment to LightNode..."

# Check if Docker and Docker Compose are installed
if ! command -v docker &> /dev/null; then
    echo "❌ Docker is not installed. Please install Docker first."
    exit 1
fi

if ! command -v docker-compose &> /dev/null; then
    echo "❌ Docker Compose is not installed. Please install Docker Compose first."
    exit 1
fi

# Check if RAILS_MASTER_KEY is set
if [ -z "$RAILS_MASTER_KEY" ]; then
    echo "❌ RAILS_MASTER_KEY environment variable is not set."
    echo "Please set it: export RAILS_MASTER_KEY=your_master_key_here"
    exit 1
fi

# Stop existing containers
echo "🛑 Stopping existing containers..."
docker-compose down || true

# Pull latest changes (if using git)
echo "📥 Pulling latest changes..."
git pull origin main || echo "⚠️  Could not pull latest changes"

# Build and start services
echo "🔨 Building and starting services..."
docker-compose up -d --build

# Wait for database to be ready
echo "⏳ Waiting for database to be ready..."
sleep 10

# Run database migrations
echo "🗄️  Running database migrations..."
docker-compose exec web rails db:migrate

# Precompile assets
echo "🎨 Precompiling assets..."
docker-compose exec web rails assets:precompile

# Restart web service to pick up changes
echo "🔄 Restarting web service..."
docker-compose restart web

echo "✅ Deployment completed successfully!"
echo "🌐 Your application should be available at: http://your-lightnode-ip"
echo "📊 Database is running on port 5432"
echo "🔴 Redis is running on port 6379"

# Show running containers
echo "📋 Running containers:"
docker-compose ps 