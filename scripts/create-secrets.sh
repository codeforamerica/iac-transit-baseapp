#!/bin/bash

# Script to create AWS Secrets Manager secret
set -e

echo "🔐 Creating AWS Secrets Manager secret..."

# Check if AWS CLI is installed and configured
if ! command -v aws &> /dev/null; then
    echo "❌ AWS CLI is not installed. Please install AWS CLI and try again."
    exit 1
fi

# Check if AWS credentials are configured
if ! aws sts get-caller-identity &> /dev/null; then
    echo "❌ AWS credentials are not configured. Please run 'aws configure' and try again."
    exit 1
fi

# Get AWS region
AWS_REGION=$(aws configure get region)
SECRET_NAME="todoapp-secrets"

echo "📋 Configuration:"
echo "   AWS Region: $AWS_REGION"
echo "   Secret Name: $SECRET_NAME"
echo ""

# Prompt for database credentials
echo "🔑 Please enter database credentials:"
read -p "Database Host (e.g., your-rds-endpoint.amazonaws.com): " DB_HOST
read -p "Database Port (default: 5432): " DB_PORT
read -p "Database Name (default: todoapp): " DB_NAME
read -p "Database Username (default: todoapp_user): " DB_USER
read -s -p "Database Password: " DB_PASSWORD
echo ""

# Set defaults
DB_PORT=${DB_PORT:-5432}
DB_NAME=${DB_NAME:-todoapp}
DB_USER=${DB_USER:-todoapp_user}

# Create secret
echo "🔐 Creating secret in AWS Secrets Manager..."

SECRET_STRING=$(cat << EOF
{
  "db_host": "$DB_HOST",
  "db_port": "$DB_PORT",
  "db_name": "$DB_NAME",
  "db_user": "$DB_USER",
  "db_password": "$DB_PASSWORD"
}
EOF
)

# Check if secret already exists
if aws secretsmanager describe-secret --secret-id "$SECRET_NAME" --region "$AWS_REGION" &> /dev/null; then
    echo "⚠️  Secret already exists. Updating..."
    aws secretsmanager update-secret \
        --secret-id "$SECRET_NAME" \
        --secret-string "$SECRET_STRING" \
        --region "$AWS_REGION"
    echo "✅ Secret updated successfully!"
else
    aws secretsmanager create-secret \
        --name "$SECRET_NAME" \
        --description "Database credentials for Todo App" \
        --secret-string "$SECRET_STRING" \
        --region "$AWS_REGION"
    echo "✅ Secret created successfully!"
fi

echo ""
echo "📊 Secret Details:"
echo "   Name: $SECRET_NAME"
echo "   Region: $AWS_REGION"
echo "   ARN: $(aws secretsmanager describe-secret --secret-id "$SECRET_NAME" --region "$AWS_REGION" --query 'ARN' --output text)"
echo ""
echo "🎉 Secret setup complete!"
echo ""
echo "📝 Next steps:"
echo "   1. Deploy the infrastructure with: ./scripts/deploy.sh"
echo "   2. The application will automatically retrieve these credentials"
echo "   3. Monitor the application logs to ensure it's working correctly"
