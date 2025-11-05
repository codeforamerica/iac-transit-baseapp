#!/bin/sh

# Get ALB DNS from environment or use default
ALB_DNS="${ALB_DNS:-localhost}"

# Generate config.json with the ALB DNS
cat > /usr/share/nginx/html/config.json <<EOF
{
  "apiUrl": "http://${ALB_DNS}:3001"
}
EOF

echo "Generated config.json with apiUrl: http://${ALB_DNS}:3001"

# Start nginx
exec nginx -g "daemon off;"
