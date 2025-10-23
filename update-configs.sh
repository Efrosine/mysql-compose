#!/bin/bash
# Script to copy configuration files into Docker volumes

echo "🔧 Updating configuration files in Docker volumes..."

# Copy phpMyAdmin config
echo "📋 Copying phpMyAdmin config..."
docker run --rm \
  -v "$(pwd)/pma-config.user.inc.php:/source/config.user.inc.php:ro" \
  -v mysql-db_pma_config:/target \
  alpine sh -c "cp /source/config.user.inc.php /target/config.user.inc.php && echo '✅ phpMyAdmin config updated'"

# Copy nginx config
echo "📋 Copying nginx config..."
docker run --rm \
  -v "$(pwd)/nginx.conf:/source/default.conf:ro" \
  -v mysql-db_nginx_config:/target \
  alpine sh -c "cp /source/default.conf /target/default.conf && echo '✅ nginx config updated'"

echo ""
echo "✨ Configuration files updated successfully!"
echo "💡 Restart containers with: docker-compose restart phpmyadmin nginx"
