# Architecture Overview

## System Architecture

The Todo App is built using a modern, cloud-native architecture designed for scalability, security, and maintainability.

### High-Level Architecture

#### GCP Architecture
```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   React SPA     │    │  Node.js API    │    │  PostgreSQL     │
│   (Frontend)    │◄──►│   (Backend)     │◄──►│   (Database)    │
└─────────────────┘    └─────────────────┘    └─────────────────┘
         │                       │                       │
         │                       │                       │
         ▼                       ▼                       ▼
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│  Cloud Run      │    │   Cloud Run     │    │   Cloud SQL     │
│  (Frontend)     │    │   (Backend)     │    │   (Managed DB)  │
└─────────────────┘    └─────────────────┘    └─────────────────┘
```

#### AWS Architecture
```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   React SPA     │    │  Node.js API    │    │  PostgreSQL     │
│   (Frontend)    │◄──►│   (Backend)     │◄──►│   (Database)    │
└─────────────────┘    └─────────────────┘    └─────────────────┘
         │                       │                       │
         │                       │                       │
         ▼                       ▼                       ▼
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   CloudFront    │    │   ECS Fargate   │    │      RDS        │
│   (CDN)         │    │   (Compute)     │    │   (Managed DB)  │
└─────────────────┘    └─────────────────┘    └─────────────────┘
```

### Component Details

#### Frontend (React SPA)
- **Technology**: React 18 with modern hooks
- **Deployment**: Containerized with Nginx
- **Features**: 
  - Responsive design with modern UI
  - Real-time todo management
  - Error handling and loading states
  - API integration with Axios

#### Backend (Node.js/Express)
- **Technology**: Node.js 18 with Express.js
- **Deployment**: 
  - **GCP**: Containerized with Cloud Run
  - **AWS**: Containerized with ECS Fargate
- **Features**:
  - RESTful API endpoints
  - Database abstraction layer
  - Secrets management integration (GCP Secret Manager / AWS Secrets Manager)
  - Comprehensive logging
  - Health check endpoints

#### Database (PostgreSQL)
- **Technology**: PostgreSQL 15
- **Deployment**: 
  - **GCP**: Cloud SQL for PostgreSQL
  - **AWS**: RDS PostgreSQL
- **Features**:
  - Automated backups
  - Performance monitoring
  - Encryption at rest
  - Connection pooling

### GCP Infrastructure

#### Compute
- **Cloud Run**: Serverless container platform
- **Auto Scaling**: Automatically scales to zero when not in use
- **HTTPS**: Built-in HTTPS with automatic SSL certificates
- **VPC Connector**: Enables private IP access to Cloud SQL

#### Networking
- **VPC Network**: Isolated network environment
- **Subnets**: Regional subnets (public and private)
- **Firewall Rules**: Network-level access control
- **VPC Flow Logs**: Network traffic logging

#### Security
- **Service Accounts**: Least privilege access
- **Secret Manager**: Secure credential storage
- **Private IP**: Cloud SQL accessible via private IP through VPC connector
- **Encryption**: At rest and in transit

#### Monitoring
- **Cloud Logging**: Centralized logging with 30-day retention
- **Cloud Monitoring**: Metrics and alerts
- **Cloud SQL Insights**: Database performance monitoring

### AWS Infrastructure

#### Compute
- **ECS Fargate**: Serverless container platform
- **Auto Scaling**: Based on CPU and memory utilization
- **Direct Access**: ECS tasks with public IPs (simplified for discovery cycle)

#### Networking
- **VPC**: Isolated network environment
- **Subnets**: Public and private subnets across multiple AZs
- **Security Groups**: Network-level access control
- **Public IPs**: ECS tasks use public IPs for internet access (cost optimization)

#### Security
- **IAM Roles**: Least privilege access
- **Secrets Manager**: Secure credential storage
- **VPC Endpoints**: Private AWS service access
- **Encryption**: At rest and in transit

#### Monitoring
- **CloudWatch**: Logs, metrics, and alarms
- **ECS Insights**: Container performance monitoring
- **RDS Monitoring**: Database performance insights

### Data Flow

1. **User Request**: User interacts with React frontend
2. **API Call**: Frontend makes HTTP request to backend API
3. **Load Balancer**: ALB routes request to healthy ECS task
4. **Backend Processing**: Express.js handles request and business logic
5. **Database Query**: Backend queries PostgreSQL via connection pool
6. **Response**: Data flows back through the same path
7. **UI Update**: Frontend updates UI with new data

### Security Architecture

#### Network Security
- VPC with public/private subnet isolation
- Security groups for fine-grained access control
- ECS tasks in public subnets with public IPs (cost optimization)
- RDS in private subnets for security
- No direct internet access to database resources

#### Application Security
- IAM roles with least privilege principle
- Secrets Manager for credential management
- HTTPS/TLS encryption for all communications
- Input validation and sanitization

#### Data Security
- Encryption at rest for RDS
- Encryption in transit for all communications
- Automated backups with retention policies
- Access logging and monitoring

### Scalability Design

#### Horizontal Scaling
- ECS Fargate auto-scaling based on demand
- Load balancer distributes traffic across instances
- Database read replicas for read-heavy workloads

#### Vertical Scaling
- Configurable CPU and memory for ECS tasks
- RDS instance class scaling
- Storage auto-scaling for RDS

### Disaster Recovery

#### Backup Strategy
- Automated RDS backups with 7-day retention
- Cross-region backup replication
- Infrastructure as Code for rapid recovery

#### High Availability
- Multi-AZ RDS deployment
- ECS tasks across multiple availability zones
- Load balancer health checks and failover

### Cost Optimization

#### Resource Optimization
- ECS Fargate for pay-per-use compute
- RDS with appropriate instance sizing
- CloudWatch log retention policies
- No NAT Gateways (ECS tasks use public IPs for cost savings)
- No ALB (direct ECS access for discovery cycle cost optimization)

#### Monitoring and Alerts
- Cost monitoring and budgeting
- Resource utilization tracking
- Automated scaling policies

## Translation Readiness

This architecture has been successfully translated from AWS to GCP and can be further translated to Azure:

### AWS → GCP (Completed ✓)
- ECS Fargate → Cloud Run (serverless containers)
- RDS PostgreSQL → Cloud SQL for PostgreSQL
- Secrets Manager → Secret Manager
- VPC → VPC Network
- ALB → Cloud Run built-in HTTPS/routing
- ECR → Artifact Registry
- CloudWatch → Cloud Logging
- IAM Roles → Service Accounts

### AWS → Azure (Future)
- ECS → Azure Container Instances
- RDS → Azure Database for PostgreSQL
- Secrets Manager → Azure Key Vault
- VPC → Azure Virtual Network
- ALB → Azure Application Gateway

### Code Adaptation Points (Completed for GCP)
- ✅ Secrets service implementation (updated to use GCP Secret Manager)
- ✅ Database connection configuration (updated for Cloud SQL private IP)
- ✅ Logging and monitoring setup (updated for Cloud Logging)
- ✅ Environment variable management (updated for GCP services)
- ✅ Deployment scripts (updated for Artifact Registry and Cloud Run)
