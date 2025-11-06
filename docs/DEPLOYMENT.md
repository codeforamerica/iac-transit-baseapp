# Deployment Guide - IaC TRANSIT Todo App

## GCP Deployment

### Prerequisites

1. **Google Cloud SDK**: Install and authenticate
   ```bash
   gcloud auth login
   gcloud config set project YOUR_PROJECT_ID
   ```

2. **Enable Required APIs**: Run the setup script
   ```bash
   ./scripts/setup-gcp.sh
   ```

3. **Update Terraform Backend**: Edit `infrastructure/main.tf` and replace `PROJECT_ID` in the GCS bucket name with your actual project ID.

### Deployment Steps

1. **Set Database Password**:
   ```bash
   export DB_PASSWORD=YourSecurePassword123
   ```

2. **Deploy Everything**:
   ```bash
   ./scripts/deploy.sh
   ```

The deployment script will:
- Build Docker images for backend and frontend
- Push images to Artifact Registry
- Deploy infrastructure with Terraform (VPC, Cloud SQL, Cloud Run, Secret Manager)
- Configure service accounts and IAM permissions
- Create Cloud Run services with proper networking

### GCP-Specific Architecture Notes

- **Cloud Run**: Services automatically scale to zero when not in use, reducing costs
- **VPC Connector**: Enables Cloud Run to access Cloud SQL via private IP
- **Secret Manager**: Database credentials stored securely and accessed at runtime
- **HTTPS**: Cloud Run services are automatically HTTPS-enabled (no load balancer needed)

### Accessing the Application

After deployment:
```bash
cd infrastructure
terraform output application_url
```

### Troubleshooting GCP Deployment

- **Image not found**: Ensure images were pushed to Artifact Registry
- **Cloud SQL connection**: Verify VPC connector is configured and Cloud Run has `cloudsql.client` role
- **Secret access**: Verify service account has `secretmanager.secretAccessor` role
- **View logs**: `gcloud logging read "resource.type=cloud_run_revision" --limit 50`

---

## AWS Deployment

## 🎯 Critical Architecture Fixes (Read First!)

This deployment guide includes several key fixes and design decisions that are **essential for reproducibility**:

### 1. **Runtime Configuration for Frontend-Backend Communication**

**The Problem:** In cloud deployment, the frontend needs to know the backend's ALB DNS name, but this isn't known until after infrastructure is deployed.

**The Solution:** 
- Frontend container has an `entrypoint.sh` script that generates `config.json` at runtime
- The script reads `ALB_DNS` environment variable and injects it into the React app
- React app loads this config via `fetch('/config.json')` on startup
- This ensures the frontend always calls the correct backend URL

**Files Involved:**
- `frontend/entrypoint.sh` - Runtime script that generates config
- `frontend/src/services/api.js` - Waits for config to load before making API calls
- `infrastructure/ecs.tf` - Passes `ALB_DNS` environment variable to frontend task

**Why This Matters:** Without this, the frontend would need to be rebuilt after infrastructure deployment, making it non-reproducible.

### 2. **CORS Configuration with Dynamic Frontend URL**

**The Problem:** Backend needs to allow requests from the frontend, but the ALB DNS name changes with each deployment.

**The Solution:**
- Backend `app.js` checks `FRONTEND_URL` environment variable in production
- Infrastructure passes `http://${aws_lb.main.dns_name}` to the backend
- CORS headers are dynamically set based on environment

**Files Involved:**
- `backend/src/app.js` - CORS configuration on lines 20-25
- `infrastructure/ecs.tf` - FRONTEND_URL environment variable passed to backend task

### 3. **Load Balancer with Port 3001 Ingress**

**The Problem:** Frontend couldn't reach backend API on port 3001 - connection timed out.

**The Solution:**
- Application Load Balancer routes frontend (port 80) and backend (port 3001)
- Security group includes ingress rule for port 3001 from internet (`0.0.0.0/0`)
- Both services registered as target groups

**Files Involved:**
- `infrastructure/load_balancer.tf` - Complete ALB configuration
- `infrastructure/security.tf` - ALB security group with port 3001 ingress

**Why This Matters:** Without the port 3001 rule, frontend gets `net::ERR_CONNECTION_TIMED_OUT` errors.

### 4. **Database Secrets with Unique Names**

**The Problem:** AWS Secrets Manager name conflicts when redeploying.

**The Solution:**
- Secret name includes account ID and timestamp: `${local.name_prefix}-db-secret-${account_id}-${timestamp}`
- Uses `aws_db_instance.main.address` instead of `.endpoint` (removes port from hostname)

**Files Involved:**
- `infrastructure/secrets.tf` - Dynamic secret naming and RDS address reference

---

## Quick Start

### Local Development (Docker Compose)

The easiest way to get started is using Docker Compose for local development.

#### Prerequisites
- Docker and Docker Compose installed
- Node.js 18+ (for local development without Docker)

#### Setup

1. **Clone the repository**
   ```bash
   git clone <repo-url>
   cd IaC_TRANSIT_baseapp
   ```

2. **Create environment file for non-sensitive config**
   ```bash
   cp .env.example .env.local
   ```
   This file contains non-sensitive configuration variables like database host, port, and frontend API URL.

3. **Set sensitive credentials via terminal exports**
   ```bash
   export DB_USER=todoapp_user
   export DB_PASSWORD=todoapp_password
   ```
   **Important:** These are for LOCAL DEVELOPMENT ONLY. For production, use AWS Secrets Manager.

4. **Start the application**
   ```bash
   docker-compose up --build
   ```
   - Frontend: http://localhost:3000
   - Backend API: http://localhost:3001
   - Database: PostgreSQL at localhost:5432

5. **Access the application**
   Open your browser and navigate to `http://localhost:3000`

#### Stopping the Application

```bash
docker-compose down
```

To also remove volumes:
```bash
docker-compose down -v
```

---

## AWS Cloud Deployment

### Prerequisites

1. **AWS Account** with appropriate permissions
2. **AWS CLI** installed and configured
   ```bash
   aws configure
   ```
3. **Terraform** installed (v1.0+)
4. **Valid AWS IAM user credentials** with permissions for:
   - EC2, ECS, RDS, VPC, IAM, S3, DynamoDB, ECR, CloudWatch, KMS, Secrets Manager
5. **Docker** installed locally (for building and pushing images)

### Architecture

The Terraform infrastructure deploys:

- **VPC** with public and private subnets
- **ECS Fargate** cluster for containerized services
- **RDS PostgreSQL** database (version 15.7)
- **ECR repositories** for backend and frontend images
- **CloudWatch** logs with KMS encryption
- **Secrets Manager** for database credentials
- **Security Groups** for network isolation
- **IAM roles** for service authentication

---

## Complete Deployment Workflow

### Step 1: Setup Terraform Backend (First Time Only)

Before initializing Terraform, create the S3 bucket and DynamoDB table:

```bash
# Export AWS credentials
export AWS_ACCESS_KEY_ID="your_key"
export AWS_SECRET_ACCESS_KEY="your_secret"
export AWS_SESSION_TOKEN="your_token"  # if using temporary credentials

# Run backend setup script
bash scripts/setup-terraform-backend.sh
```

This creates:
- S3 bucket for Terraform state with versioning and encryption
- DynamoDB table for state locking
- Proper access controls and security settings

### Step 2: Initialize Terraform

```bash
cd infrastructure
terraform init
```

### Step 3: Build and Push Docker Images to ECR

Before applying Terraform, you need to build and push the Docker images:

```bash
# Get your AWS Account ID
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
REGION="us-east-1"

# Login to ECR
aws ecr get-login-password --region $REGION | docker login --username AWS --password-stdin $ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com

# Build and push backend image
docker build -t todoapp-backend ./backend
docker tag todoapp-backend:latest $ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com/todoapp-dev-backend:latest
docker push $ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com/todoapp-dev-backend:latest

# Install react-scripts locally (required for frontend build)
cd frontend
npm install
cd ..

# Build and push frontend image
docker build -t todoapp-frontend ./frontend
docker tag todoapp-frontend:latest $ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com/todoapp-dev-frontend:latest
docker push $ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com/todoapp-dev-frontend:latest
```

**Important:** Make sure `react-scripts` is installed locally in the frontend directory before building the image. If you get "react-scripts: not found" errors, run `npm install` in the frontend directory.

### 🍎 Building on Apple Silicon (M1/M2/M3/M4)

If you're on Apple Silicon, you **must build images for Linux AMD64** (the Fargate architecture):

```bash
# Enable Docker buildx for multi-platform builds (one-time setup)
docker buildx create --name multiplatform --use

# Build backend for AMD64
docker buildx build --platform linux/amd64 -t todoapp-backend:latest ./backend
docker tag todoapp-backend:latest $ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com/todoapp-dev-backend:latest
docker push $ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com/todoapp-dev-backend:latest

# Build frontend for AMD64
cd frontend && npm install && cd ..
docker buildx build --platform linux/amd64 -t todoapp-frontend:latest ./frontend
docker tag todoapp-frontend:latest $ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com/todoapp-dev-frontend:latest
docker push $ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com/todoapp-dev-frontend:latest
```

**Why:** Fargate only supports `linux/amd64`. Building with Apple Silicon (ARM64) will cause "image Manifest does not contain descriptor matching platform 'linux/amd64'" errors in ECS.

### Step 4: Plan Infrastructure Changes

```bash
terraform plan \
  -var="aws_region=us-east-1" \
  -var="db_password=YourSecurePassword123" \
  -out=tfplan
```

Review the plan to see what resources will be created.

### Step 5: Apply Terraform Configuration

```bash
terraform apply tfplan
```

This will create:
- VPC and networking infrastructure
- RDS PostgreSQL database
- ECS cluster and services (using the images you pushed)
- Security groups and IAM roles
- CloudWatch logs and monitoring
- Secrets Manager entries for database credentials

**Expected Duration:** 8-15 minutes

### Step 6: Verify Deployment

```bash
# Get output values
terraform output

# Check ECS services
aws ecs describe-services \
  --cluster todoapp-dev \
  --services todoapp-backend todoapp-frontend \
  --region us-east-1

# View logs
aws logs tail /ecs/todoapp-dev --follow --region us-east-1
```

---

## Troubleshooting

### Image Not Found Errors

If ECS can't find the images, ensure:
1. ✅ Images were successfully pushed to ECR (check AWS Console)
2. ✅ ECR repository names match Terraform config (`todoapp-dev-backend`, `todoapp-dev-frontend`)
3. ✅ Image tags are correct (`:latest`)

### React-scripts Build Failure

If frontend Docker build fails with "react-scripts: not found":
```bash
cd frontend
npm install
npm run build  # Test build locally
cd ..
docker build -t todoapp-frontend ./frontend
```

### Session Token Expired

If you get "InvalidClientTokenId" errors:
```bash
# Re-export AWS credentials
export AWS_ACCESS_KEY_ID="your_key"
export AWS_SECRET_ACCESS_KEY="your_secret"
export AWS_SESSION_TOKEN="your_token"

# Verify credentials work
aws sts get-caller-identity
```

### Resource Already Exists Errors

These are now handled with `force_delete` flags. If you still encounter them:
```bash
terraform destroy -auto-approve
terraform apply tfplan
```

---

## Local Development vs Production

- **Local:** Use `docker-compose up` with `.env.local` and terminal exports
- **Production:** Use Terraform-managed infrastructure on AWS with Secrets Manager

See [Local Development](#local-development-docker-compose) for local setup.
