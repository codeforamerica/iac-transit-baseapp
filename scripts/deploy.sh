#!/bin/bash

# Deployment script for GCP
set -e

echo "🚀 Deploying Todo App to GCP..."

# Check if gcloud CLI is installed and configured
if ! command -v gcloud &> /dev/null; then
    echo "❌ gcloud CLI is not installed. Please install Google Cloud SDK and try again."
    exit 1
fi

# Check if user is authenticated
if ! gcloud auth list --filter=status:ACTIVE --format="value(account)" &> /dev/null; then
    echo "❌ No active gcloud authentication found. Please run 'gcloud auth login' and try again."
    exit 1
fi

# Check if Terraform is installed
if ! command -v terraform &> /dev/null; then
    echo "❌ Terraform is not installed. Please install Terraform and try again."
    exit 1
fi

# Get GCP project ID and region
GCP_PROJECT_ID=$(gcloud config get-value project 2>/dev/null)
if [ -z "$GCP_PROJECT_ID" ]; then
    echo "❌ No GCP project is set. Please set a project with 'gcloud config set project PROJECT_ID'"
    exit 1
fi

GCP_REGION=${GCP_REGION:-us-central1}
ARTIFACT_REGISTRY_LOCATION=${ARTIFACT_REGISTRY_LOCATION:-us-central1}

echo "📋 Deployment Configuration:"
echo "   GCP Project ID: $GCP_PROJECT_ID"
echo "   GCP Region: $GCP_REGION"
echo ""

# Configure Docker for Artifact Registry
echo "🔐 Configuring Docker for Artifact Registry..."
gcloud auth configure-docker ${ARTIFACT_REGISTRY_LOCATION}-docker.pkg.dev --quiet

# Build and push Docker images
echo "🔨 Building and pushing Docker images..."

# Backend image
echo "📦 Building backend image..."
cd backend
docker build -t todoapp-backend:latest .

BACKEND_REPO="${ARTIFACT_REGISTRY_LOCATION}-docker.pkg.dev/${GCP_PROJECT_ID}/todoapp-dev-backend"
docker tag todoapp-backend:latest ${BACKEND_REPO}/backend:latest

echo "📤 Pushing backend image to Artifact Registry..."
docker push ${BACKEND_REPO}/backend:latest
cd ..

# Frontend image
echo "📦 Building frontend image..."
cd frontend
# Install react-scripts locally if needed
if [ ! -d "node_modules" ]; then
    echo "📥 Installing frontend dependencies..."
    npm install
fi
docker build -t todoapp-frontend:latest .

FRONTEND_REPO="${ARTIFACT_REGISTRY_LOCATION}-docker.pkg.dev/${GCP_PROJECT_ID}/todoapp-dev-frontend"
docker tag todoapp-frontend:latest ${FRONTEND_REPO}/frontend:latest

echo "📤 Pushing frontend image to Artifact Registry..."
docker push ${FRONTEND_REPO}/frontend:latest
cd ..

# Deploy infrastructure with Terraform
echo "🏗️  Deploying infrastructure with Terraform..."
cd infrastructure

# Initialize Terraform
terraform init

# Plan deployment
echo "📋 Planning Terraform deployment..."
terraform plan \
  -var="gcp_project_id=${GCP_PROJECT_ID}" \
  -var="gcp_region=${GCP_REGION}" \
  -var="db_password=${DB_PASSWORD:-ChangeMe123!}" \
  -out=tfplan

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
echo "🔧 Backend Service URL: $(terraform output -raw backend_service_url)"
echo "🗄️  Cloud SQL Connection: $(terraform output -raw cloud_sql_connection_name)"
echo ""
echo "📝 Next steps:"
echo "   1. Monitor the application in the GCP Console"
echo "   2. Check Cloud Logging for any issues"
echo "   3. Verify Cloud Run services are running correctly"
