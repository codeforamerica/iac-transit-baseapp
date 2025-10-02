# Architecture Overview

## System Architecture

The Todo App is built using a modern, cloud-native architecture designed for scalability, security, and maintainability.

### High-Level Architecture

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
- **Deployment**: Containerized with ECS Fargate
- **Features**:
  - RESTful API endpoints
  - Database abstraction layer
  - Secrets management integration
  - Comprehensive logging
  - Health check endpoints

#### Database (PostgreSQL)
- **Technology**: PostgreSQL 15
- **Deployment**: AWS RDS with Multi-AZ
- **Features**:
  - Automated backups
  - Performance monitoring
  - Encryption at rest
  - Connection pooling

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

This architecture is designed to be easily translatable to other cloud platforms:

### AWS → Azure
- ECS → Azure Container Instances
- RDS → Azure Database for PostgreSQL
- Secrets Manager → Azure Key Vault
- VPC → Azure Virtual Network
- ALB → Azure Application Gateway

### AWS → GCP
- ECS → Cloud Run
- RDS → Cloud SQL
- Secrets Manager → Secret Manager
- VPC → VPC Network
- ALB → Cloud Load Balancing

### Code Adaptation Points
- Secrets service implementation
- Database connection configuration
- Logging and monitoring setup
- Environment variable management
