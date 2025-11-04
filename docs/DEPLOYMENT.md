# Deployment Guide - IaC TRANSIT Todo App

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
   - EC2
   - ECS
   - RDS
   - VPC
   - IAM
   - S3 (for Terraform state)
   - DynamoDB (for state locking)

### Architecture

The Terraform infrastructure deploys:

- **VPC** with public and private subnets
- **ECS Fargate** cluster for containerized services
- **Application Load Balancer** (optional, can be removed for cost optimization)
- **RDS PostgreSQL** database
- **Security Groups** for network isolation
- **CloudWatch** logs for monitoring

### Step 1: Setup Terraform Backend

Before deploying infrastructure, create the S3 bucket and DynamoDB table for Terraform state management:

```bash
# Verify AWS credentials work
aws sts get-caller-identity

# Run the backend setup script
bash scripts/setup-terraform-backend.sh
```

This script will:
- Create S3 bucket `iac-transit-terraform-state`
- Enable versioning and encryption
- Create DynamoDB table `terraform-locks` for state locking

### Step 2: Initialize Terraform

```bash
cd infrastructure
terraform init
```

This will:
- Download AWS provider
- Configure S3 backend
- Create Terraform lock file

### Step 3: Configure Terraform Variables

Review and customize `infrastructure/terraform.tfvars` or create one:

```hcl
aws_region       = "us-east-1"
environment      = "production"
project_name     = "todoapp"
app_count        = 2
container_cpu    = 256
container_memory = 512
```

### Step 4: Plan Terraform Changes

```bash
terraform plan -out=tfplan
```

Review the output to see what resources will be created.

### Step 5: Apply Terraform Configuration

```bash
terraform apply tfplan
```

This will create all AWS infrastructure.

### Step 6: Deploy Application

The Terraform configuration includes:
- **ECR repositories** for Docker images
- **ECS task definitions** for services
- **ECS services** to run tasks

To deploy:

1. **Build and push Docker images to ECR**
   ```bash
   # Backend
   docker build -t todoapp-backend ./backend
   docker tag todoapp-backend:latest <account-id>.dkr.ecr.us-east-1.amazonaws.com/todoapp-backend:latest
   docker push <account-id>.dkr.ecr.us-east-1.amazonaws.com/todoapp-backend:latest
   
   # Frontend
   docker build -t todoapp-frontend ./frontend
   docker tag todoapp-frontend:latest <account-id>.dkr.ecr.us-east-1.amazonaws.com/todoapp-frontend:latest
   docker push <account-id>.dkr.ecr.us-east-1.amazonaws.com/todoapp-frontend:latest
   ```

2. **Update ECS service**
   ```bash
   aws ecs update-service \
     --cluster todoapp-production \
     --service todoapp-backend \
     --force-new-deployment
   ```

---

## Environment Variables

### Local Development (.env.local)

Non-sensitive configuration stored in `.env.local`:

```bash
# Node.js Environment
NODE_ENV=development
API_PORT=3001

# Database Configuration (non-sensitive)
DB_HOST=db
DB_PORT=5432
DB_NAME=todoapp

# Frontend Configuration
REACT_APP_API_URL=http://localhost:3001
```

**Important:** `.env.local` is Git-ignored but can be version controlled with non-sensitive defaults. Never commit sensitive credentials here.

### Production (AWS Secrets Manager)

Sensitive credentials should be stored in AWS Secrets Manager:

```bash
# Database credentials
aws secretsmanager create-secret \
  --name todoapp/db/username \
  --secret-string todoapp_user

aws secretsmanager create-secret \
  --name todoapp/db/password \
  --secret-string <strong-password>
```

ECS task definitions will retrieve these at runtime.

---

## Security Best Practices

### 1. Credential Management

**✅ DO:**
- Use AWS Secrets Manager for production secrets
- Use IAM roles for service authentication
- Rotate credentials regularly

**❌ DON'T:**
- Commit `.env` files with credentials
- Pass secrets through `docker-compose` environment blocks
- Use hardcoded credentials in source code

### 2. Database

**✅ DO:**
- Use RDS with encrypted connections
- Enable backups and Multi-AZ
- Use strong passwords (min 16 characters)
- Restrict security group access

**❌ DON'T:**
- Use default credentials
- Expose database to 0.0.0.0/0
- Skip encryption

### 3. Container Security

**✅ DO:**
- Run containers as non-root user
- Use minimal base images (Alpine, Slim)
- Scan images for vulnerabilities

**❌ DON'T:**
- Run as root in production
- Use `latest` tag in production
- Include secrets in Dockerfile

---

## Monitoring & Logs

### CloudWatch Logs

View application logs:

```bash
# Backend logs
aws logs tail /ecs/todoapp-backend --follow

# Frontend logs
aws logs tail /ecs/todoapp-frontend --follow
```

### Metrics

Key metrics to monitor:
- CPU utilization
- Memory utilization
- Database connections
- API response time
- Error rates

---

## Troubleshooting

### AWS Credentials Error

```
InvalidClientTokenId: The security token included in the request is invalid
```

**Solution:**
1. Verify credentials in AWS console
2. Check if access key is active and not expired
3. Re-run `aws configure` with correct credentials
4. Verify IAM user has required permissions

### Terraform State Lock

If Terraform is stuck:

```bash
# Release lock
terraform force-unlock <LOCK_ID>
```

### ECS Task Failures

Check task logs:

```bash
aws ecs describe-tasks \
  --cluster todoapp-production \
  --tasks <task-arn>
```

---

## Cost Optimization

### Recommendations

1. **Use Fargate Spot** for non-production (up to 70% savings)
2. **Scale down at night** using ECS scheduled tasks
3. **Use smaller instance types** for testing
4. **Enable S3 lifecycle policies** for state backups

### Estimated Monthly Costs (Production)

- ECS Fargate: ~$50
- RDS: ~$30
- Data Transfer: ~$5
- S3 (state): <$1
- **Total: ~$85/month**

---

## Cleanup

To destroy infrastructure and avoid costs:

```bash
cd infrastructure
terraform destroy
```

**Warning:** This will delete:
- All ECS services and tasks
- RDS database (if not configured for retention)
- Load balancer
- VPC and networking

Data in S3 and DynamoDB will NOT be deleted automatically.

---

## Support

For issues or questions:
1. Check CloudWatch logs
2. Review Terraform state: `terraform show`
3. Check AWS console for resource status
4. Review security group rules and routing tables
