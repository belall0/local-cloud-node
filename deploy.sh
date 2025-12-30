#!/bin/bash
set -e

DOMAIN="$1"

if [ -z "$DOMAIN" ]; then
  echo "Usage: npm run deploy <domain>"
  echo "Example: npm run deploy api.example.com"
  exit 1
fi

export DOMAIN

# Sanitize domain for project name (replace dots with dashes)
PROJECT_NAME="${DOMAIN//./-}"

echo "Deploying instance for domain: $DOMAIN"
echo "Project name: $PROJECT_NAME"

# Start the infrastructure services in the main project (no -p flag)
# This ensures nginx-proxy and acme-companion are shared across all deployments
docker compose up -d nginx-proxy acme-companion

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

cat > "/tmp/compose-${PROJECT_NAME}.yaml" << EOF
services:
  app:
    build:
      context: ${SCRIPT_DIR}
      dockerfile: Dockerfile
    container_name: ${DOMAIN}
    environment:
      - VIRTUAL_HOST=${DOMAIN}
      - LETSENCRYPT_HOST=${DOMAIN}
      - VIRTUAL_PORT=3000
    networks:
      - nginx-proxy
    restart: always

networks:
  nginx-proxy:
    external: true
    name: node_nginx-proxy
EOF

docker compose -f "/tmp/compose-${PROJECT_NAME}.yaml" -p "$PROJECT_NAME" up -d --build

rm -f "/tmp/compose-${PROJECT_NAME}.yaml"

echo ""
echo "Deployment complete for $DOMAIN"
echo "Container name: $DOMAIN"
