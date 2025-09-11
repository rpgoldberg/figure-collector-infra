#!/bin/bash

# Setup script for Docker Registry with authentication

set -e

echo "Setting up Docker Registry..."

# Create auth directory
mkdir -p auth

# Generate htpasswd file for basic auth
echo "Creating registry user..."
read -p "Enter username for registry: " USERNAME
docker run --rm --entrypoint htpasswd registry:2 -Bbn $USERNAME > auth/htpasswd

echo "Registry authentication configured."

# Create self-signed certificate for HTTPS (production should use Let's Encrypt)
mkdir -p certs
openssl req -newkey rsa:4096 -nodes -sha256 -keyout certs/registry.key \
  -x509 -days 365 -out certs/registry.crt \
  -subj "/C=US/ST=State/L=City/O=Organization/CN=registry.local"

echo "SSL certificates generated."

# Create .env file for sensitive values
cat > .env << EOF
HARBOR_DB_PASSWORD=$(openssl rand -base64 32)
HARBOR_ADMIN_PASSWORD=$(openssl rand -base64 32)
EOF

echo "Environment variables configured."

# Start the registry
docker compose -f docker-compose.registry.yml up -d

echo "Docker Registry is starting..."
echo ""
echo "Registry URL: http://localhost:5000"
echo "Registry UI: http://localhost:5001"
echo ""
echo "To login to the registry:"
echo "  docker login localhost:5000"
echo ""
echo "To push images:"
echo "  docker tag <image> localhost:5000/<image>:<tag>"
echo "  docker push localhost:5000/<image>:<tag>"