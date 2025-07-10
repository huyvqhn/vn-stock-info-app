#!/bin/bash

# Deploy script using Kamal for LightNode instance
set -e

echo "🚀 Starting Kamal deployment to LightNode..."

# Check if Kamal is installed
if ! command -v kamal &> /dev/null; then
    echo "❌ Kamal is not installed. Installing Kamal..."
    gem install kamal
fi

# Check if RAILS_MASTER_KEY is set
if [ -z "$RAILS_MASTER_KEY" ]; then
    echo "❌ RAILS_MASTER_KEY environment variable is not set."
    echo "Please set it: export RAILS_MASTER_KEY=your_master_key_here"
    exit 1
fi

# Check if deploy.yml exists
if [ ! -f "deploy.yml" ]; then
    echo "❌ deploy.yml not found. Please configure deployment first."
    exit 1
fi

# Check SSH connection to server
echo "🔑 Testing SSH connection..."
if ! ssh -o ConnectTimeout=10 -o BatchMode=yes deploy@38.54.30.6 exit 2>/dev/null; then
    echo "❌ Cannot connect to server. Please check SSH configuration."
    echo "Run: ssh-copy-id deploy@38.54.30.6"
    exit 1
fi

echo "✅ SSH connection successful!"

# Check if this is first deployment
if [ "$1" = "--setup" ] || [ "$1" = "-s" ]; then
    echo "🔧 First time setup - creating database and running migrations..."
    kamal deploy --setup
else
    echo "📦 Deploying application..."
    kamal deploy
fi

# Wait a moment for deployment to complete
echo "⏳ Waiting for deployment to complete..."
sleep 10

# Check deployment status
echo "📊 Checking deployment status..."
kamal status

# Show logs
echo "📋 Recent logs:"
kamal app logs --tail=20

echo "✅ Kamal deployment completed successfully!"
echo "🌐 Your application should be available at: http://38.54.30.6"
echo "📊 Database is running in container"
echo "🔴 Redis is running in container"

# Show useful commands
echo ""
echo "📚 Useful commands:"
echo "  kamal status          - Check service status"
echo "  kamal app logs        - View application logs"
echo "  kamal app exec bash   - Access application container"
echo "  kamal env             - View environment variables"
echo "  kamal restart         - Restart application" 