#!/bin/sh

# Get Cloud Run URL from environment or use default
if [ -z "$CLOUD_RUN_URL" ]; then
  CLOUD_RUN_URL="http://localhost:3001"
fi

# Generate config.json with the Cloud Run URL
cat > /usr/share/nginx/html/config.json <<EOF
{
  "apiUrl": "${CLOUD_RUN_URL}"
}
EOF

echo "Generated config.json with apiUrl: ${CLOUD_RUN_URL}"

# Start nginx
exec nginx -g "daemon off;"
