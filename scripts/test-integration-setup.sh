#!/bin/bash

# Quick test to verify integration test setup
set -e

echo "🧪 Testing Integration Test Setup"
echo "================================"

# Check if we're in the right directory
if [ ! -f "integration-test-runner.sh" ]; then
    echo "❌ Must run from project root (where integration-test-runner.sh is located)"
    exit 1
fi

# Create results directory
echo "📁 Creating integration-test-results directory..."
mkdir -p ./integration-test-results
echo "✅ Directory created: $(pwd)/integration-test-results"

# Check Docker is running
if ! docker info > /dev/null 2>&1; then
    echo "❌ Docker is not running. Please start Docker first."
    exit 1
fi
echo "✅ Docker is running"

# Check docker-compose is available
if ! command -v docker-compose &> /dev/null; then
    echo "❌ docker-compose is not installed"
    exit 1
fi
echo "✅ docker-compose is available"

# Validate compose file
if [ ! -f "docker-compose.integration.yml" ]; then
    echo "❌ docker-compose.integration.yml not found"
    exit 1
fi
echo "✅ Docker Compose file found"

# Test compose file syntax
echo "🔍 Validating Docker Compose configuration..."
if docker-compose -f docker-compose.integration.yml config > /dev/null; then
    echo "✅ Docker Compose configuration is valid"
else
    echo "❌ Docker Compose configuration has errors"
    exit 1
fi

# List available services
echo ""
echo "📋 Available services:"
docker-compose -f docker-compose.integration.yml config --services | sed 's/^/  - /'

echo ""
echo "🎉 Integration test setup is ready!"
echo ""
echo "Usage:"
echo "  ./integration-test-runner.sh run     # Run full integration tests"
echo "  ./integration-test-runner.sh debug   # Start services for manual testing"
echo "  ./integration-test-runner.sh clean   # Clean up containers"
echo ""
echo "Results will be saved to: $(pwd)/integration-test-results/"