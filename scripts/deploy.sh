#!/bin/bash

# Deployment script for AWS
set -e

echo "🚀 Deploying Todo App to AWS..."

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

# Check if Terraform is installed
if ! command -v terraform &> /dev/null; then
    echo "❌ Terraform is not installed. Please install Terraform and try again."
    exit 1
fi

# Get AWS account ID and region
AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
AWS_REGION=$(aws configure get region)

echo "📋 Deployment Configuration:"
echo "   AWS Account ID: $AWS_ACCOUNT_ID"
echo "   AWS Region: $AWS_REGION"
echo ""

# Build and push Docker images
echo "🔨 Building and pushing Docker images..."

# Backend image
echo "📦 Building backend image..."
cd backend
docker build -t todoapp-backend .
docker tag todoapp-backend:latest $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/todoapp-dev-backend:latest

echo "📤 Pushing backend image to ECR..."
aws ecr get-login-password --region $AWS_REGION | docker login --username AWS --password-stdin $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com
docker push $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/todoapp-dev-backend:latest
cd ..

# Frontend image
echo "📦 Building frontend image..."
cd frontend
docker build -t todoapp-frontend .
docker tag todoapp-frontend:latest $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/todoapp-dev-frontend:latest

echo "📤 Pushing frontend image to ECR..."
docker push $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/todoapp-dev-frontend:latest
cd ..

# Deploy infrastructure with Terraform
echo "🏗️  Deploying infrastructure with Terraform..."
cd infrastructure

# Initialize Terraform
terraform init

# Plan deployment
echo "📋 Planning Terraform deployment..."
terraform plan -out=tfplan

# Apply deployment
echo "🚀 Applying Terraform deployment..."
terraform apply tfplan

# Get outputs
echo "📊 Deployment outputs:"
terraform output

echo ""
echo "🎉 Deployment complete!"
echo ""
echo "🌐 Application URL: $(terraform output -raw application_url)"
echo "📊 ECS Cluster: $(terraform output -raw ecs_cluster_name)"
echo "🗄️  RDS Endpoint: $(terraform output -raw rds_endpoint)"
echo ""
echo "📝 Next steps:"
echo "   1. Update your DNS to point to the ALB if using a custom domain"
echo "   2. Monitor the application in the AWS Console"
echo "   3. Check CloudWatch logs for any issues"
