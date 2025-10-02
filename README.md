# IaC TRANSIT Base App - To-Do Application

A simple, sleek To-Do application built for testing Infrastructure as Code (IaC) translation between AWS, Azure, and GCP. 

## Discovery Cycle Purpose

This base app will be used for our discovery cycle to test how AI tools translate Infrastructure as Code (IaC) between AWS, Azure, and GCP—using a simple full-stack app—to simplify migrations. The goal is to assess tool effectiveness, with deliverables including findings, guidance, and a practical playbook for engineers and architects.

This base app is AWS-native and designed to be translated to other cloud platforms using AI tools.

## Architecture

- **Frontend**: React SPA with modern, sleek UI
- **Backend**: Node.js/Express API
- **Database**: RDS PostgreSQL (AWS) / Local JSON for development
- **Infrastructure**: AWS ECS Fargate, RDS, Secrets Manager, VPC (simplified for discovery cycle)
- **Secrets Management**: AWS Secrets Manager (production) / Environment variables (local)

## Quick Start

### Prerequisites

- Node.js 18+
- Docker & Docker Compose
- AWS CLI (for cloud deployment)
- Terraform (for infrastructure)

### Local Development

1. **Clone and setup**:
   ```bash
   git clone <repo-url>
   cd IaC_TRANSIT_baseapp
   cp .env.example .env
   ```

2. **Set up environment variables** (choose one method):

   **Method 1: Command line**
   ```bash
   export DB_HOST=localhost
   export DB_PORT=5432
   export DB_NAME=todoapp
   export DB_USER=todoapp_user
   export DB_PASSWORD=your_password
   ```

   **Method 2: .env.local file** (gitignored)
   ```bash
   # Create .env.local with sensitive variables
   echo "DB_HOST=localhost" >> .env.local
   echo "DB_PORT=5432" >> .env.local
   echo "DB_NAME=todoapp" >> .env.local
   echo "DB_USER=todoapp_user" >> .env.local
   echo "DB_PASSWORD=your_password" >> .env.local
   ```

3. **Start the application**:
   ```bash
   # Using Docker Compose (recommended)
   docker-compose up

   # Or manually
   cd backend && npm install && npm start
   cd frontend && npm install && npm start
   ```

4. **Access the app**: http://localhost:3000

### AWS Deployment

1. **Create AWS Secrets Manager secret**:
   ```bash
   aws secretsmanager create-secret \
     --name todoapp-secrets \
     --description "Todo app database credentials" \
     --secret-string '{
       "db_host": "your-rds-endpoint.amazonaws.com",
       "db_port": "5432",
       "db_name": "todoapp",
       "db_user": "todoapp_user",
       "db_password": "your_secure_password"
     }'
   ```

2. **Deploy infrastructure**:
   ```bash
   cd infrastructure
   terraform init
   terraform plan
   terraform apply
   ```

3. **Deploy application**:
   ```bash
   ./scripts/deploy.sh
   ```

## Environment Variables

### Non-sensitive (.env file)
```bash
API_PORT=3001
NODE_ENV=development
AWS_REGION=us-east-1
SECRETS_MANAGER_SECRET_NAME=todoapp-secrets
REACT_APP_API_URL=http://localhost:3001
```

### Sensitive (command line or AWS Secrets Manager)
```bash
DB_HOST=localhost
DB_PORT=5432
DB_NAME=todoapp
DB_USER=todoapp_user
DB_PASSWORD=your_password
```

## Security

- **Never commit sensitive data** to version control
- **Use AWS Secrets Manager** for production deployments
- **Use command-line environment variables** for local testing
- **.env.local files** are gitignored for local development

## Translation Guide

This AWS-native application is designed to be translated to other cloud platforms:

### AWS → Azure
- ECS → Azure Container Instances
- RDS → Azure Database for PostgreSQL
- Secrets Manager → Azure Key Vault
- VPC → Azure Virtual Network

### AWS → GCP
- ECS → Cloud Run
- RDS → Cloud SQL
- Secrets Manager → Secret Manager
- VPC → VPC Network

## API Endpoints

- `GET /api/todos` - Get all todos
- `POST /api/todos` - Create a new todo
- `PUT /api/todos/:id` - Update a todo
- `DELETE /api/todos/:id` - Delete a todo
- `GET /api/health` - Health check

## Contributing

This is a base template for IaC translation testing. Feel free to modify and extend as needed for your specific use case.

## Cost Considerations

- RDS: ~$15–20/month (db.t3.micro)
- ECS Fargate: ~$10–15/month (256 CPU, 512 MB)
- Data transfer: minimal for testing

**Total: ~$25–35/month for the simplified stack.**

*Note: ALB and NAT Gateways have been removed to reduce costs for the discovery cycle. ECS tasks run in public subnets with direct public IPs, while RDS remains in private subnets for security.*

## License

MIT
