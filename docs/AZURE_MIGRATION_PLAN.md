# AWS to Azure Migration Plan

## Quick Reference Summary

**Migration Approach:**
- ✅ Azure account already exists - no account setup required
- ✅ **100% Terraform-managed** - All infrastructure provisioned via Terraform (no manual configuration)
- ✅ **All resources prefixed with `group-c-`** - Namespace isolation requirement
- ✅ **Leverage existing AWS Terraform** - Use AWS Terraform files as reference for Azure implementation

**Key Migration Path:**
1. **Week 1**: Set up Terraform backend in Azure Storage, establish `group-c-` naming conventions
2. **Weeks 2-3**: Create Azure Terraform files (mirroring AWS structure) with `group-c-` prefix
3. **Weeks 4-5**: Update application code (secrets service, environment variables)
4. **Weeks 6-7**: Build containers, deploy via Terraform
5. **Week 8**: Migrate database
6. **Week 9**: Testing and validation
7. **Week 10**: Production cutover, AWS cleanup

**Terraform Structure:**
```
infrastructure/
├── aws/     # Existing (reference)
└── azure/   # New (Terraform-managed, group-c- prefix)
```

---

## Executive Summary

This document outlines a comprehensive migration plan for moving the Todo App infrastructure and application from AWS to Azure using **Terraform as the primary infrastructure provisioning tool**. The migration will preserve functionality while adapting to Azure's service ecosystem and best practices.

**Key Requirements:**
- Azure account already exists and is available for use
- All infrastructure will be provisioned using Terraform (no manual configuration)
- All Azure resources must be prefixed with `group-c-` for namespace isolation
- Migration will leverage existing AWS Terraform code as a reference for Azure Terraform implementation

**Current AWS Stack (Terraform-managed):**
- ECS Fargate (Container Orchestration)
- RDS PostgreSQL (Database)
- Application Load Balancer (ALB)
- ECR (Container Registry)
- AWS Secrets Manager
- CloudWatch Logs
- VPC (Networking)
- KMS (Encryption)
- S3 + DynamoDB (Terraform Backend)

**Target Azure Stack (Terraform-managed):**
- Azure Container Apps (Container Orchestration)
- Azure Database for PostgreSQL Flexible Server
- Azure Application Gateway (Load Balancing)
- Azure Container Registry (ACR)
- Azure Key Vault (Secrets Management)
- Azure Monitor / Log Analytics (Monitoring)
- Azure Virtual Network (Networking)
- Azure Key Vault (Encryption)
- Azure Storage Account + Blob Storage (Terraform Backend)

---

## Table of Contents

1. [Service Mapping](#service-mapping)
2. [Migration Phases](#migration-phases)
3. [Infrastructure Migration](#infrastructure-migration)
4. [Application Code Changes](#application-code-changes)
5. [Data Migration](#data-migration)
6. [Testing Strategy](#testing-strategy)
7. [Rollback Plan](#rollback-plan)
8. [Timeline and Resources](#timeline-and-resources)
9. [Cost Comparison](#cost-comparison)
10. [Risk Assessment](#risk-assessment)

---

## Service Mapping

### Core Services

| AWS Service | Azure Equivalent | Notes |
|------------|------------------|-------|
| **ECS Fargate** | **Azure Container Apps** (recommended) or **Azure Container Instances** | Container Apps provides better orchestration, scaling, and integration |
| **RDS PostgreSQL** | **Azure Database for PostgreSQL - Flexible Server** | Similar managed service with auto-scaling and backups |
| **Application Load Balancer (ALB)** | **Azure Application Gateway** or **Azure Front Door** | Application Gateway for regional, Front Door for global |
| **ECR** | **Azure Container Registry (ACR)** | Fully managed container registry |
| **AWS Secrets Manager** | **Azure Key Vault** | Similar secret management with versioning |
| **CloudWatch Logs** | **Azure Monitor / Log Analytics Workspace** | Centralized logging and monitoring |
| **VPC** | **Azure Virtual Network (VNet)** | Similar networking concepts |
| **Security Groups** | **Network Security Groups (NSG)** | Similar firewall rules |
| **KMS** | **Azure Key Vault** | Key management and encryption |
| **IAM Roles** | **Managed Identities** | Service-to-service authentication |
| **S3 (Terraform Backend)** | **Azure Storage Account (Blob)** | Object storage for Terraform state |
| **DynamoDB (State Locking)** | **Azure Storage Account (Table)** or **Azure Cosmos DB** | State locking mechanism |

### Networking Components

| AWS Component | Azure Equivalent |
|--------------|------------------|
| VPC | Virtual Network (VNet) |
| Subnet | Subnet |
| Internet Gateway | Not needed (VNet has internet access by default) |
| Route Table | Route Table |
| Security Group | Network Security Group (NSG) |
| VPC Flow Logs | NSG Flow Logs |

### Monitoring and Logging

| AWS Service | Azure Equivalent |
|------------|------------------|
| CloudWatch Logs | Log Analytics Workspace |
| CloudWatch Metrics | Azure Monitor Metrics |
| CloudWatch Alarms | Azure Monitor Alerts |
| VPC Flow Logs | NSG Flow Logs |

---

## Migration Phases

### Phase 1: Preparation and Planning (Week 1)

**Objectives:**
- Set up Terraform backend in Azure Storage
- Document current AWS infrastructure Terraform code
- Create Azure resource naming conventions with `group-c-` prefix
- Set up Azure authentication for Terraform

**Tasks:**
1. **Azure Authentication Setup**
   - Verify Azure account access and permissions
   - Configure Azure CLI authentication (`az login`)
   - Set up service principal or use Azure CLI authentication for Terraform
   - Verify required Azure provider permissions

2. **Terraform Backend Setup**
   - Create Azure Storage Account for Terraform state (name: `group-c-terraform-state`)
   - Create blob container for state files (`tfstate`)
   - Configure state locking using Azure Storage Table (`terraform-locks`)
   - Update Terraform backend configuration in `infrastructure/azure/main.tf`
   - Test Terraform backend connectivity

3. **Resource Naming Convention**
   - Document `group-c-` prefix requirement for all resources
   - Create naming pattern: `group-c-{resource-type}-{environment}-{identifier}`
   - Examples:
     - Resource Group: `group-c-rg-dev`
     - VNet: `group-c-vnet-dev`
     - Container Registry: `group-c-acr-dev`
     - Key Vault: `group-c-kv-dev`
     - PostgreSQL: `group-c-postgres-dev`
     - Container Apps: `group-c-ca-backend-dev`, `group-c-ca-frontend-dev`

4. **AWS Infrastructure Documentation**
   - Review existing AWS Terraform files in `infrastructure/` directory
   - Document resource configurations and dependencies
   - Map AWS Terraform resources to Azure Terraform resources
   - Identify configuration values to migrate

**Deliverables:**
- Terraform backend configured in Azure Storage
- Azure authentication working
- Resource naming convention document
- AWS infrastructure inventory and mapping document

---

### Phase 2: Terraform Infrastructure Development (Week 2-3)

**Objectives:**
- Create Azure Terraform modules based on AWS Terraform structure
- Implement all infrastructure components using Terraform
- Ensure all resources use `group-c-` prefix
- Test Terraform plan and apply operations

**Tasks:**
1. **Create Azure Terraform Directory Structure**
   ```
   infrastructure/
   ├── aws/              # Existing AWS infrastructure (keep for reference)
   │   ├── main.tf
   │   ├── ecs.tf
   │   ├── rds.tf
   │   └── ...
   └── azure/            # New Azure infrastructure
       ├── main.tf
       ├── providers.tf
       ├── variables.tf
       ├── outputs.tf
       ├── locals.tf      # Contains 'group-c-' prefix logic
       ├── networking.tf
       ├── container_registry.tf
       ├── key_vault.tf
       ├── database.tf
       ├── container_apps.tf
       ├── monitoring.tf
       ├── load_balancer.tf
       └── security.tf
   ```

2. **Implement Core Terraform Files**
   - **`locals.tf`**: Define naming conventions with `group-c-` prefix
   - **`providers.tf`**: Configure Azure provider
   - **`main.tf`**: Terraform backend configuration, provider setup
   - **`variables.tf`**: Define input variables (mirror AWS variables where applicable)
   - **`outputs.tf`**: Define output values for other modules/scripts

3. **Networking Infrastructure (`networking.tf`)**
   - Create Resource Group: `group-c-rg-{env}`
   - Create Virtual Network: `group-c-vnet-{env}`
   - Create public and private subnets with `group-c-` prefix
   - Create Network Security Groups (NSG) with `group-c-` prefix
   - Configure NSG rules (map from AWS Security Groups)
   - Set up NSG Flow Logs to Log Analytics

4. **Container Registry (`container_registry.tf`)**
   - Create Azure Container Registry: `group-c-acr-{env}`
   - Configure authentication (Admin user or Managed Identity)
   - Set up image retention policies
   - Configure geo-replication if needed

5. **Key Vault (`key_vault.tf`)**
   - Create Azure Key Vault: `group-c-kv-{env}`
   - Configure access policies for Managed Identities
   - Create secrets (database credentials) - values from variables or AWS Secrets Manager
   - Set up soft-delete and purge protection

6. **Database (`database.tf`)**
   - Create Azure Database for PostgreSQL Flexible Server: `group-c-postgres-{env}`
   - Configure firewall rules (allow Azure services, specific IPs)
   - Set up private endpoint (optional, for enhanced security)
   - Configure backup retention (31 days to match AWS)
   - Enable performance monitoring
   - Configure storage auto-grow

7. **Monitoring (`monitoring.tf`)**
   - Create Log Analytics Workspace: `group-c-law-{env}`
   - Configure diagnostic settings for all resources
   - Set up Azure Monitor alert rules
   - Configure NSG Flow Logs to Log Analytics

8. **Load Balancer (`load_balancer.tf`)**
   - Create Application Gateway: `group-c-agw-{env}`
   - Configure backend pools
   - Set up routing rules
   - Configure health probes
   - Set up SSL/TLS certificates (optional)

9. **Container Apps (`container_apps.tf`)**
   - Create Container Apps Environment: `group-c-cae-{env}`
   - Create Backend Container App: `group-c-ca-backend-{env}`
   - Create Frontend Container App: `group-c-ca-frontend-{env}`
   - Configure Managed Identities
   - Set up environment variables
   - Configure scaling rules
   - Set up ingress configuration

10. **Security (`security.tf`)**
    - Configure Managed Identities for all services
    - Set up role assignments
    - Configure Key Vault access policies
    - Set up network security rules

**Terraform Development Process:**
1. Start with `terraform init` in `infrastructure/azure/` directory
2. Create files incrementally (networking first, then dependencies)
3. Use `terraform plan` frequently to validate configuration
4. Test with `terraform apply` in development environment
5. Review and validate all resource names include `group-c-` prefix

**Deliverables:**
- Complete Azure Terraform infrastructure code
- All resources prefixed with `group-c-`
- Terraform plan executes successfully
- Infrastructure can be provisioned with `terraform apply`

---

### Phase 3: Application Code Updates (Week 4-5)

**Objectives:**
- Update application code to use Azure services instead of AWS
- Modify secrets service to use Azure Key Vault
- Update logging configuration for Azure Monitor
- Update environment variables and configuration
- Test application locally with Azure services

**Tasks:**
1. **Update Package Dependencies**
   - Remove AWS SDK: `npm uninstall aws-sdk`
   - Install Azure SDK packages:
     ```bash
     npm install @azure/keyvault-secrets @azure/identity
     ```
   - Update `backend/package.json`

2. **Secrets Service Migration**
   - **File**: `backend/src/services/secretsService.js`
   - Replace AWS Secrets Manager code with Azure Key Vault
   - Implement `DefaultAzureCredential` for Managed Identity authentication
   - Add fallback to environment variables for local development
   - Update secret retrieval logic to use Azure Key Vault REST API
   - Test secret retrieval locally (using Azure CLI authentication)

3. **Environment Variables Updates**
   - **File**: `.env.example`
   - Replace AWS-specific variables:
     - `AWS_REGION` → `AZURE_REGION` (optional, for reference)
     - `SECRETS_MANAGER_SECRET_NAME` → `AZURE_KEY_VAULT_URL`
   - Add new Azure-specific variables:
     - `AZURE_KEY_VAULT_URL=https://group-c-kv-{env}.vault.azure.net/`
   - Update `backend/src/services/secretsService.js` to use new variable names
   - Document all environment variable changes

4. **Logging Configuration**
   - **File**: `backend/src/utils/logger.js`
   - Container Apps automatically captures stdout/stderr to Log Analytics
   - No code changes required for basic logging
   - Optional: Add Application Insights SDK for advanced monitoring
   - Verify log format is compatible with Azure Log Analytics queries

5. **Docker Configuration**
   - Review `backend/Dockerfile` - no changes needed (uses Node.js base image)
   - Review `frontend/Dockerfile` - no changes needed
   - Test container builds locally
   - Verify images can be pushed to ACR

6. **Update Documentation**
   - Update `README.md` with Azure deployment instructions
   - Update environment variable documentation
   - Add Azure-specific setup instructions

**Code Changes Summary:**

**Before (AWS):**
```javascript
// backend/src/services/secretsService.js
const AWS = require('aws-sdk');
const secretsManager = new AWS.SecretsManager({ region: process.env.AWS_REGION });
```

**After (Azure):**
```javascript
// backend/src/services/secretsService.js
const { SecretClient } = require('@azure/keyvault-secrets');
const { DefaultAzureCredential } = require('@azure/identity');
```

**Deliverables:**
- Updated `secretsService.js` using Azure Key Vault
- Updated environment variables and `.env.example`
- Application code tested locally with Azure services
- Updated documentation
- Container images tested and ready for ACR

---

### Phase 4: Container Build and Deployment (Week 6-7)

**Objectives:**
- Build and push container images to Azure Container Registry
- Deploy infrastructure using Terraform (includes Container Apps)
- Configure and test end-to-end application flow
- Validate all services are operational

**Tasks:**
1. **Build and Push Container Images**
   ```bash
   # Authenticate with ACR
   az acr login --name group-c-acr-{env}
   
   # Build and tag backend image
   docker build -t group-c-acr-{env}.azurecr.io/backend:latest ./backend
   docker push group-c-acr-{env}.azurecr.io/backend:latest
   
   # Build and tag frontend image
   docker build -t group-c-acr-{env}.azurecr.io/frontend:latest ./frontend
   docker push group-c-acr-{env}.azurecr.io/frontend:latest
   ```

2. **Deploy Infrastructure with Terraform**
   ```bash
   cd infrastructure/azure
   terraform init
   terraform plan -var="environment=dev" -var="db_password=<secure-password>"
   terraform apply
   ```
   - This will create all Azure resources including:
     - Container Apps Environment
     - Backend Container App
     - Frontend Container App
     - Application Gateway
     - All networking and security resources

3. **Verify Terraform Deployment**
   - Check all resources created with `group-c-` prefix
   - Verify Container Apps are running
   - Verify database is accessible
   - Verify Key Vault has secrets
   - Check Terraform outputs for endpoints and connection strings

4. **Configure Container Apps (via Terraform)**
   - Backend Container App:
     - Image: `group-c-acr-{env}.azurecr.io/backend:latest`
     - Environment variables (from Terraform variables)
     - Key Vault integration (Managed Identity)
     - Health check: `/api/health`
     - Ingress: Internal (for Application Gateway)
   - Frontend Container App:
     - Image: `group-c-acr-{env}.azurecr.io/frontend:latest`
     - Environment variables (API URL pointing to Application Gateway)
     - Health check: `/`
     - Ingress: Public

5. **Application Gateway Configuration (via Terraform)**
   - Backend pool: Backend Container App
   - Frontend pool: Frontend Container App
   - Routing rules:
     - `/api/*` → Backend Container App
     - `/*` → Frontend Container App
   - Health probes configured
   - SSL/TLS certificates (if using HTTPS)

6. **Testing and Validation**
   - Test backend API endpoints via Application Gateway
   - Test frontend application
   - Verify database connectivity from Container Apps
   - Test secret retrieval from Key Vault (check logs)
   - Verify logging to Azure Monitor/Log Analytics
   - Test health check endpoints
   - Verify scaling behavior (if configured)

**Deliverables:**
- Container images in ACR
- All infrastructure deployed via Terraform
- Backend and frontend running in Container Apps
- Application Gateway configured and routing correctly
- End-to-end application tested and validated

---

### Phase 5: Data Migration (Week 8)

**Objectives:**
- Migrate database schema and data from AWS RDS to Azure PostgreSQL
- Validate data integrity
- Test application with migrated data

**Tasks:**
1. **Pre-Migration Setup**
   - Azure PostgreSQL should already be created via Terraform
   - Get database connection details from Terraform outputs:
     ```bash
     cd infrastructure/azure
     terraform output postgres_fqdn
     terraform output postgres_admin_username
     ```
   - Configure firewall rules in Terraform to allow migration source IP
   - Test connection from local machine to Azure PostgreSQL

2. **Schema Migration**
   - Export schema from AWS RDS:
     ```bash
     pg_dump -h <aws-rds-endpoint> \
             -U <username> \
             -d todoapp \
             --schema-only \
             -f schema.sql
     ```
   - Review and adapt schema if needed (Azure PostgreSQL compatibility)
   - Import schema to Azure PostgreSQL:
     ```bash
     psql -h <azure-postgres-fqdn> \
          -U <admin-username> \
          -d todoapp \
          -f schema.sql
     ```

3. **Data Migration**
   - **Option A: pg_dump / pg_restore (Recommended)**
     ```bash
     # Export data from AWS RDS
     pg_dump -h <aws-rds-endpoint> \
             -U <username> \
             -d todoapp \
             --data-only \
             --no-owner \
             --no-privileges \
             -F c \
             -f data.dump
     
     # Import data to Azure PostgreSQL
     pg_restore -h <azure-postgres-fqdn> \
                -U <admin-username> \
                -d todoapp \
                --no-owner \
                --no-privileges \
                data.dump
     ```
   - **Option B: Azure Database Migration Service (DMS)** - For zero-downtime migration
   - **Option C: Application-level migration** - Export via API, import via API

4. **Data Validation**
   - Compare record counts:
     ```sql
     -- AWS RDS
     SELECT COUNT(*) FROM todos;
     
     -- Azure PostgreSQL
     SELECT COUNT(*) FROM todos;
     ```
   - Spot-check data integrity (compare sample records)
   - Verify foreign keys and constraints
   - Test application queries with migrated data
   - Run application test suite against migrated database

5. **Update Application Configuration**
   - Update Key Vault secrets with Azure PostgreSQL connection details (if changed)
   - Or update via Terraform to ensure consistency
   - Restart Container Apps to pick up new database connection

6. **Cutover Preparation**
   - Plan maintenance window (if needed)
   - Prepare rollback procedure
   - Document cutover steps
   - Create backup of AWS RDS before final cutover

**Deliverables:**
- Database schema migrated to Azure PostgreSQL
- Data migrated and validated
- Application tested with migrated data
- Migration documentation

---

### Phase 6: Testing and Validation (Week 9)

**Objectives:**
- Comprehensive testing of migrated application
- Performance testing
- Security validation
- Terraform infrastructure validation
- User acceptance testing

**Tasks:**
1. **Infrastructure Validation**
   - Verify all resources have `group-c-` prefix
   - Validate Terraform state is correct
   - Test Terraform destroy and recreate (infrastructure as code validation)
   - Verify resource dependencies and ordering

2. **Functional Testing**
   - Test all API endpoints via Application Gateway
   - Test frontend functionality
   - Test error handling
   - Test edge cases
   - Verify health check endpoints

3. **Performance Testing**
   - Load testing (using tools like Apache JMeter or k6)
   - Response time validation
   - Database query performance
   - Container Apps scaling behavior
   - Application Gateway performance

4. **Security Testing**
   - Verify secrets are stored in Key Vault (not in environment variables)
   - Test Managed Identity authentication
   - Test network security (NSG rules)
   - Verify encryption at rest and in transit
   - Test Key Vault access policies
   - Verify no hardcoded credentials in code or Terraform

5. **Integration Testing**
   - Test end-to-end workflows
   - Test database transactions
   - Test logging to Azure Monitor/Log Analytics
   - Test Container Apps connectivity to database
   - Test Application Gateway routing

6. **Monitoring and Observability**
   - Verify logs are appearing in Log Analytics Workspace
   - Test Azure Monitor alerts
   - Verify NSG Flow Logs are working
   - Test diagnostic settings

**Deliverables:**
- Test results document
- Performance benchmarks
- Security validation report
- Infrastructure validation report
- Issues log and resolutions

---

### Phase 7: Cutover and Go-Live (Week 10)

**Objectives:**
- Execute production cutover
- Monitor application health
- Validate all systems operational
- Clean up AWS resources (after validation period)

**Tasks:**
1. **Pre-Cutover**
   - Final data sync (if using DMS or incremental migration)
   - DNS cutover preparation (if using custom domain)
   - Communication to stakeholders
   - Final backup of AWS resources
   - Document rollback procedure

2. **Cutover Execution**
   - Switch DNS to Azure Application Gateway (if using custom domain)
   - Or update application configuration to point to Azure endpoints
   - Verify all Azure services are running:
     ```bash
     # Check Container Apps
     az containerapp list --resource-group group-c-rg-{env}
     
     # Check Application Gateway
     az network application-gateway show --name group-c-agw-{env} --resource-group group-c-rg-{env}
     
     # Check database
     az postgres flexible-server show --name group-c-postgres-{env} --resource-group group-c-rg-{env}
     ```
   - Monitor Azure Monitor dashboards for errors
   - Test application functionality

3. **Post-Cutover Validation**
   - Monitor application metrics in Azure Monitor
   - Check Log Analytics for errors
   - Verify user access and functionality
   - Validate all API endpoints
   - Test database connectivity
   - Verify secret retrieval from Key Vault
   - Check Application Gateway health probes

4. **AWS Infrastructure Cleanup (After 7-14 Day Validation Period)**
   - Keep AWS resources running for validation period
   - Monitor both environments during transition
   - After successful validation:
     ```bash
     cd infrastructure/aws
     terraform destroy
     ```
   - Verify all AWS resources are destroyed
   - Final cost reconciliation (AWS vs Azure)

5. **Documentation and Handoff**
   - Update all documentation with Azure deployment instructions
   - Document Terraform usage and maintenance
   - Create runbook for common operations
   - Train team on Azure services and Terraform infrastructure

**Deliverables:**
- Application running on Azure
- Monitoring dashboards active
- Cutover documentation
- Post-migration report
- AWS resources cleaned up (after validation)
- Updated documentation and runbooks

---

## Infrastructure Migration

### Terraform Structure for Azure

Create a new directory structure for Azure infrastructure, mirroring the AWS structure:

```
infrastructure/
├── aws/              # Existing AWS infrastructure (keep for reference)
│   ├── main.tf
│   ├── ecs.tf
│   ├── rds.tf
│   ├── networking.tf
│   ├── load_balancer.tf
│   ├── secrets.tf
│   ├── cloudwatch.tf
│   ├── iam.tf
│   ├── security.tf
│   ├── variables.tf
│   └── outputs.tf
└── azure/            # New Azure infrastructure (Terraform-managed)
    ├── main.tf       # Backend config, provider setup
    ├── providers.tf  # Azure provider configuration
    ├── locals.tf     # Naming conventions with 'group-c-' prefix
    ├── variables.tf  # Input variables
    ├── outputs.tf    # Output values
    ├── networking.tf # VNet, subnets, NSGs (maps from aws/networking.tf)
    ├── container_registry.tf # ACR (maps from aws/ecs.tf ECR resources)
    ├── key_vault.tf  # Key Vault (maps from aws/secrets.tf)
    ├── database.tf   # PostgreSQL (maps from aws/rds.tf)
    ├── container_apps.tf # Container Apps (maps from aws/ecs.tf)
    ├── monitoring.tf # Log Analytics, Monitor (maps from aws/cloudwatch.tf)
    ├── load_balancer.tf # Application Gateway (maps from aws/load_balancer.tf)
    └── security.tf   # Managed Identities, role assignments (maps from aws/iam.tf)
```

### Migration Approach: AWS Terraform → Azure Terraform

The migration will follow this pattern:
1. **Reference AWS Terraform files** to understand resource configurations
2. **Map AWS resources to Azure equivalents** (see Service Mapping section)
3. **Create Azure Terraform files** with equivalent functionality
4. **Use `group-c-` prefix** for all Azure resource names
5. **Maintain similar structure** to AWS Terraform for easier maintenance

### Key Terraform Files for Azure

#### `azure/locals.tf` - Naming Conventions
```hcl
locals {
  name_prefix = "group-c-${var.environment}"
  
  common_tags = {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "Terraform"
    Namespace   = "group-c"
  }
  
  # Resource naming with group-c- prefix
  resource_group_name     = "${local.name_prefix}-rg"
  vnet_name               = "${local.name_prefix}-vnet"
  acr_name                = "${local.name_prefix}-acr"
  key_vault_name          = "${local.name_prefix}-kv"
  postgres_server_name    = "${local.name_prefix}-postgres"
  container_app_env_name  = "${local.name_prefix}-cae"
  backend_app_name        = "${local.name_prefix}-ca-backend"
  frontend_app_name       = "${local.name_prefix}-ca-frontend"
  app_gateway_name        = "${local.name_prefix}-agw"
  log_analytics_name      = "${local.name_prefix}-law"
}
```

#### `azure/main.tf` - Backend and Provider
```hcl
terraform {
  required_version = ">= 1.0"
  
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }

  backend "azurerm" {
    resource_group_name  = "group-c-terraform-state-rg"
    storage_account_name = "groupctfstate"  # Must be globally unique
    container_name       = "tfstate"
    key                  = "todoapp/terraform.tfstate"
  }
}

provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

# Data sources
data "azurerm_client_config" "current" {}
```

#### `azure/networking.tf` (Maps from `aws/networking.tf`)
- Resource Group: `group-c-{env}-rg`
- Virtual Network (VNet): `group-c-{env}-vnet`
- Public Subnets: `group-c-{env}-subnet-public-{1,2}`
- Private Subnets: `group-c-{env}-subnet-private-{1,2}`
- Network Security Groups (NSG): `group-c-{env}-nsg-{purpose}`
- NSG Rules (map from AWS Security Group rules)
- NSG Flow Logs to Log Analytics

#### `azure/container_registry.tf` (Maps from `aws/ecs.tf` ECR resources)
- Azure Container Registry: `group-c-{env}-acr`
- Admin user enabled (or Managed Identity)
- Image retention policies
- Geo-replication (optional)

#### `azure/key_vault.tf` (Maps from `aws/secrets.tf`)
- Azure Key Vault: `group-c-{env}-kv`
- Secrets: `db-host`, `db-port`, `db-name`, `db-user`, `db-password`
- Access policies for Managed Identities
- Soft-delete and purge protection enabled

#### `azure/database.tf` (Maps from `aws/rds.tf`)
- Azure Database for PostgreSQL Flexible Server: `group-c-{env}-postgres`
- Firewall rules (allow Azure services, specific IPs)
- Private endpoint (optional, for enhanced security)
- Backup retention: 31 days (to match AWS)
- Performance monitoring enabled
- Storage auto-grow configured

#### `azure/container_apps.tf` (Maps from `aws/ecs.tf`)
- Container Apps Environment: `group-c-{env}-cae`
- Backend Container App: `group-c-{env}-ca-backend`
- Frontend Container App: `group-c-{env}-ca-frontend`
- Managed Identities for each app
- Environment variables
- Scaling rules (CPU/memory based)
- Ingress configuration
- Health check endpoints

#### `azure/monitoring.tf` (Maps from `aws/cloudwatch.tf`)
- Log Analytics Workspace: `group-c-{env}-law`
- Diagnostic settings for all resources
- Azure Monitor alert rules
- NSG Flow Logs to Log Analytics
- Container Apps log streaming

#### `azure/load_balancer.tf` (Maps from `aws/load_balancer.tf`)
- Application Gateway: `group-c-{env}-agw`
- Backend pools (Container Apps)
- Routing rules:
  - `/api/*` → Backend Container App
  - `/*` → Frontend Container App
- Health probes
- SSL/TLS certificates (optional)

#### `azure/security.tf` (Maps from `aws/iam.tf`)
- Managed Identities for Container Apps
- Role assignments (Key Vault access, etc.)
- Network Security Group rules
- Key Vault access policies

---

## Application Code Changes

### 1. Secrets Service Update

**File:** `backend/src/services/secretsService.js`

**Current (AWS):**
```javascript
const AWS = require('aws-sdk');
const secretsManager = new AWS.SecretsManager({ region: process.env.AWS_REGION });
```

**Updated (Azure):**
```javascript
const { SecretClient } = require('@azure/keyvault-secrets');
const { DefaultAzureCredential } = require('@azure/identity');

class SecretsService {
  constructor() {
    const keyVaultUrl = process.env.AZURE_KEY_VAULT_URL;
    const credential = new DefaultAzureCredential();
    this.secretClient = new SecretClient(keyVaultUrl, credential);
    this.cachedSecrets = null;
    this.cacheExpiry = null;
    this.cacheDuration = 5 * 60 * 1000; // 5 minutes
  }

  async getSecrets() {
    // Return cached secrets if still valid
    if (this.cachedSecrets && this.cacheExpiry && Date.now() < this.cacheExpiry) {
      return this.cachedSecrets;
    }

    try {
      if (process.env.NODE_ENV === 'production' && process.env.AZURE_KEY_VAULT_URL) {
        logger.info('Fetching secrets from Azure Key Vault');
        
        const dbHost = await this.secretClient.getSecret('db-host');
        const dbPort = await this.secretClient.getSecret('db-port');
        const dbName = await this.secretClient.getSecret('db-name');
        const dbUser = await this.secretClient.getSecret('db-user');
        const dbPassword = await this.secretClient.getSecret('db-password');
        
        const secrets = {
          db_host: dbHost.value,
          db_port: dbPort.value,
          db_name: dbName.value,
          db_user: dbUser.value,
          db_password: dbPassword.value
        };
        
        this.cachedSecrets = secrets;
        this.cacheExpiry = Date.now() + this.cacheDuration;
        
        logger.info('Successfully retrieved secrets from Azure Key Vault');
        return secrets;
      } else {
        // Local development - use environment variables
        logger.info('Using environment variables for local development');
        
        const secrets = {
          db_host: process.env.DB_HOST || 'localhost',
          db_port: process.env.DB_PORT || '5432',
          db_name: process.env.DB_NAME || 'todoapp',
          db_user: process.env.DB_USER || 'todoapp_user',
          db_password: process.env.DB_PASSWORD || 'todoapp_password'
        };

        this.cachedSecrets = secrets;
        this.cacheExpiry = Date.now() + this.cacheDuration;
        
        return secrets;
      }
    } catch (error) {
      logger.error('Failed to retrieve secrets:', error);
      // Fallback to environment variables
      // ... (similar to current implementation)
    }
  }
}
```

**Package Updates:**
```json
{
  "dependencies": {
    "@azure/keyvault-secrets": "^4.7.0",
    "@azure/identity": "^3.0.0"
  }
}
```

### 2. Logging Updates

**File:** `backend/src/utils/logger.js`

Consider adding Azure Monitor integration:
- Use `@azure/monitor-opentelemetry-exporter` for OpenTelemetry
- Or use Application Insights SDK
- Or continue using console logs (Container Apps can capture stdout/stderr)

### 3. Environment Variables

**Update `.env.example`:**
```bash
# Azure Configuration
AZURE_KEY_VAULT_URL=https://your-keyvault.vault.azure.net/
AZURE_REGION=eastus

# Database (fallback for local dev)
DB_HOST=localhost
DB_PORT=5432
DB_NAME=todoapp
DB_USER=todoapp_user
DB_PASSWORD=your_password

# Application
API_PORT=3001
NODE_ENV=development
REACT_APP_API_URL=http://localhost:3001
```

### 4. Dockerfile Updates

No major changes needed, but ensure:
- Base images are compatible
- Health check endpoints are configured
- Ports are correctly exposed

---

## Data Migration

### Option 1: pg_dump / pg_restore (Recommended for Small Databases)

**Steps:**
1. Export from AWS RDS:
   ```bash
   pg_dump -h <aws-rds-endpoint> \
           -U <username> \
           -d todoapp \
           -F c \
           -f backup.dump
   ```

2. Import to Azure PostgreSQL:
   ```bash
   pg_restore -h <azure-postgres-endpoint> \
              -U <username> \
              -d todoapp \
              --no-owner \
              --no-privileges \
              backup.dump
   ```

### Option 2: Azure Database Migration Service (DMS)

For zero-downtime migration:
1. Create DMS instance
2. Configure source (AWS RDS) and target (Azure PostgreSQL)
3. Run migration assessment
4. Execute migration
5. Monitor and validate

### Option 3: Application-Level Migration

For minimal downtime:
1. Export data via API endpoints
2. Import data via API endpoints
3. Validate data integrity

---

## Testing Strategy

### Unit Tests
- Test secrets service with Azure Key Vault
- Test database service with Azure PostgreSQL
- Test API endpoints

### Integration Tests
- Test end-to-end workflows
- Test database connectivity
- Test secret retrieval
- Test logging

### Performance Tests
- Load testing with k6 or Apache JMeter
- Database query performance
- Container scaling behavior
- Response time validation

### Security Tests
- Verify secrets are not exposed
- Test NSG rules
- Verify encryption
- Test authentication

### User Acceptance Tests
- Test all user-facing features
- Test error handling
- Test edge cases

---

## Rollback Plan

### Rollback Triggers
- Critical application errors
- Data integrity issues
- Performance degradation
- Security vulnerabilities

### Rollback Steps
1. **Immediate Actions**
   - Switch DNS back to AWS (if applicable)
   - Or update application configuration to point to AWS
   - Verify AWS resources are still running

2. **Data Rollback**
   - If data was migrated, restore from AWS RDS backup
   - Or re-sync data from AWS to Azure if needed

3. **Infrastructure Rollback**
   - Keep Azure resources running for 7-14 days
   - After validation, destroy Azure resources if rollback is permanent
   - Or keep both environments running during transition

### Rollback Validation
- Verify application functionality
- Verify data integrity
- Verify performance metrics
- Document rollback reasons

---

## Timeline and Resources

### Estimated Timeline: 10 Weeks

| Phase | Duration | Resources | Key Activities |
|-------|----------|-----------|----------------|
| Phase 1: Preparation | 1 week | 1 DevOps Engineer | Terraform backend setup, naming conventions |
| Phase 2: Terraform Infrastructure | 2 weeks | 1 DevOps Engineer | Create all Azure Terraform files |
| Phase 3: Code Updates | 2 weeks | 1 Backend Developer | Update secrets service, environment variables |
| Phase 4: Container Deployment | 2 weeks | 1 DevOps Engineer | Build images, deploy via Terraform |
| Phase 5: Data Migration | 1 week | 1 Database Administrator | Migrate database schema and data |
| Phase 6: Testing | 1 week | 1 QA Engineer, 1 Developer | Comprehensive testing |
| Phase 7: Cutover | 1 week | Full team | Production cutover, AWS cleanup |

### Resource Requirements
- **DevOps Engineer**: Terraform development, infrastructure provisioning, deployment
- **Backend Developer**: Application code updates, Azure SDK integration
- **Database Administrator**: Data migration, validation
- **QA Engineer**: Testing, validation
- **Cloud Architect**: Architecture review, Terraform code review (optional)

### Key Milestones
- **Week 1**: Terraform backend configured, naming conventions established
- **Week 3**: All Azure Terraform files created and tested
- **Week 5**: Application code updated and tested locally
- **Week 7**: Infrastructure deployed, containers running
- **Week 8**: Database migrated and validated
- **Week 9**: All testing completed
- **Week 10**: Production cutover, AWS resources cleaned up

---

## Cost Comparison

### AWS Current Costs (Monthly)
- RDS (db.t3.micro): ~$15-20
- ECS Fargate (256 CPU, 512 MB): ~$10-15
- ALB: ~$16-20
- ECR: ~$0.50
- CloudWatch Logs: ~$2-5
- VPC Flow Logs: ~$0.50
- KMS: ~$1
- **Total: ~$45-62/month**

### Azure Estimated Costs (Monthly)
- Azure Database for PostgreSQL (Basic tier, 2 vCores): ~$30-40
- Azure Container Apps (Consumption plan): ~$10-20
- Application Gateway (Basic tier): ~$20-25
- Azure Container Registry (Basic): ~$5
- Log Analytics Workspace: ~$2-5
- Key Vault (Standard): ~$0.03 per 10,000 operations
- **Total: ~$67-95/month**

**Note:** Costs vary based on usage, region, and pricing tiers. Azure may be slightly more expensive initially, but offers different pricing models and potential savings with reserved instances.

---

## Risk Assessment

### High Risk
1. **Data Loss During Migration**
   - **Mitigation**: Multiple backups, validation steps, rollback plan
   - **Probability**: Low
   - **Impact**: Critical

2. **Application Downtime**
   - **Mitigation**: Blue-green deployment, gradual cutover
   - **Probability**: Medium
   - **Impact**: High

3. **Performance Degradation**
   - **Mitigation**: Performance testing, optimization
   - **Probability**: Medium
   - **Impact**: Medium

### Medium Risk
1. **Configuration Errors**
   - **Mitigation**: Comprehensive testing, documentation
   - **Probability**: Medium
   - **Impact**: Medium

2. **Secret Management Issues**
   - **Mitigation**: Thorough testing, fallback mechanisms
   - **Probability**: Low
   - **Impact**: Medium

3. **Network Connectivity Issues**
   - **Mitigation**: Proper NSG configuration, testing
   - **Probability**: Low
   - **Impact**: Medium

### Low Risk
1. **Cost Overruns**
   - **Mitigation**: Budget alerts, cost monitoring
   - **Probability**: Low
   - **Impact**: Low

2. **Documentation Gaps**
   - **Mitigation**: Continuous documentation updates
   - **Probability**: Medium
   - **Impact**: Low

---

## Success Criteria

### Technical Success
- ✅ All AWS services successfully migrated to Azure
- ✅ Application functionality preserved
- ✅ Performance meets or exceeds AWS baseline
- ✅ Security posture maintained or improved
- ✅ Monitoring and logging operational

### Business Success
- ✅ Zero data loss
- ✅ Minimal downtime (< 4 hours)
- ✅ Cost within 20% of AWS baseline
- ✅ Team trained on Azure services
- ✅ Documentation complete

---

## Post-Migration Tasks

### Week 1-2 After Migration
- Monitor application performance
- Review cost reports
- Address any issues
- Optimize resource configurations

### Week 3-4 After Migration
- Fine-tune scaling rules
- Optimize database performance
- Review and adjust monitoring alerts
- Cost optimization

### Ongoing
- Regular backup validation
- Security audits
- Performance monitoring
- Cost optimization reviews

---

## Additional Resources

### Azure Documentation
- [Azure Container Apps Documentation](https://docs.microsoft.com/azure/container-apps/)
- [Azure Database for PostgreSQL](https://docs.microsoft.com/azure/postgresql/)
- [Azure Key Vault](https://docs.microsoft.com/azure/key-vault/)
- [Azure Virtual Network](https://docs.microsoft.com/azure/virtual-network/)

### Migration Tools
- [Azure Database Migration Service](https://docs.microsoft.com/azure/dms/)
- [Azure Migrate](https://docs.microsoft.com/azure/migrate/)
- [Azure CLI](https://docs.microsoft.com/cli/azure/)

### Support
- Azure Support Plans
- Azure Architecture Center
- Azure Community Forums

---

## Appendix

### A. Terraform Backend Setup Script

```bash
#!/bin/bash
# setup-azure-terraform-backend.sh
# Creates Azure Storage Account and container for Terraform state

RESOURCE_GROUP="group-c-terraform-state-rg"
STORAGE_ACCOUNT="groupctfstate$(date +%s | tail -c 5)"  # Append random suffix for uniqueness
CONTAINER_NAME="tfstate"
LOCATION="eastus"

# Create resource group
az group create --name $RESOURCE_GROUP --location $LOCATION

# Create storage account
az storage account create \
  --resource-group $RESOURCE_GROUP \
  --name $STORAGE_ACCOUNT \
  --sku Standard_LRS \
  --encryption-services blob

# Get storage account key
ACCOUNT_KEY=$(az storage account keys list \
  --resource-group $RESOURCE_GROUP \
  --account-name $STORAGE_ACCOUNT \
  --query [0].value -o tsv)

# Create blob container
az storage container create \
  --name $CONTAINER_NAME \
  --account-name $STORAGE_ACCOUNT \
  --account-key $ACCOUNT_KEY

# Create table for state locking (optional, using Storage Table)
az storage table create \
  --name terraform-locks \
  --account-name $STORAGE_ACCOUNT \
  --account-key $ACCOUNT_KEY

echo "Storage Account: $STORAGE_ACCOUNT"
echo "Resource Group: $RESOURCE_GROUP"
echo "Container: $CONTAINER_NAME"
echo ""
echo "Update infrastructure/azure/main.tf with these values:"
echo "  storage_account_name = \"$STORAGE_ACCOUNT\""
echo "  resource_group_name  = \"$RESOURCE_GROUP\""
```

### B. Database Migration Script

```bash
#!/bin/bash
# migrate-database.sh

# Export from AWS RDS
pg_dump -h $AWS_RDS_ENDPOINT \
        -U $AWS_DB_USER \
        -d todoapp \
        -F c \
        -f backup.dump

# Import to Azure PostgreSQL
pg_restore -h $AZURE_POSTGRES_ENDPOINT \
           -U $AZURE_DB_USER \
           -d todoapp \
           --no-owner \
           --no-privileges \
           backup.dump

# Validate
psql -h $AZURE_POSTGRES_ENDPOINT -U $AZURE_DB_USER -d todoapp -c "SELECT COUNT(*) FROM todos;"
```

### C. Migration Checklist Template

```
Migration Checklist - AWS to Azure (Terraform-managed)

Phase 1: Preparation
- [ ] Azure account access verified
- [ ] Azure CLI authenticated (az login)
- [ ] Terraform backend storage account created (group-c-terraform-state-rg)
- [ ] Terraform backend configured in infrastructure/azure/main.tf
- [ ] Resource naming convention documented (group-c- prefix)
- [ ] AWS infrastructure Terraform files reviewed and documented

Phase 2: Terraform Infrastructure Development
- [ ] infrastructure/azure/ directory structure created
- [ ] locals.tf created with group-c- naming conventions
- [ ] providers.tf and main.tf configured
- [ ] variables.tf created (mirroring AWS variables)
- [ ] outputs.tf created
- [ ] networking.tf implemented (VNet, subnets, NSGs)
- [ ] container_registry.tf implemented
- [ ] key_vault.tf implemented
- [ ] database.tf implemented
- [ ] container_apps.tf implemented
- [ ] monitoring.tf implemented
- [ ] load_balancer.tf implemented
- [ ] security.tf implemented (Managed Identities)
- [ ] All resources verified with group-c- prefix
- [ ] terraform init successful
- [ ] terraform plan successful
- [ ] terraform apply tested in dev environment

Phase 3: Application Code Updates
- [ ] AWS SDK removed from package.json
- [ ] Azure SDK packages installed (@azure/keyvault-secrets, @azure/identity)
- [ ] secretsService.js updated to use Azure Key Vault
- [ ] Environment variables updated (.env.example)
- [ ] Application tested locally with Azure Key Vault
- [ ] Container images build successfully
- [ ] Documentation updated

Phase 4: Container Deployment
- [ ] Container images built and tagged
- [ ] Images pushed to ACR (group-c-acr-{env})
- [ ] Terraform apply executed (all infrastructure)
- [ ] Container Apps Environment created
- [ ] Backend Container App deployed and running
- [ ] Frontend Container App deployed and running
- [ ] Application Gateway configured
- [ ] End-to-end application tested

Phase 5: Data Migration
- [ ] Database schema exported from AWS RDS
- [ ] Schema imported to Azure PostgreSQL
- [ ] Data exported from AWS RDS
- [ ] Data imported to Azure PostgreSQL
- [ ] Data validation completed (record counts, spot checks)
- [ ] Application tested with migrated data

Phase 6: Testing
- [ ] All resources have group-c- prefix verified
- [ ] Functional testing completed
- [ ] Performance testing completed
- [ ] Security testing completed
- [ ] Integration testing completed
- [ ] Monitoring and logging verified

Phase 7: Cutover
- [ ] Pre-cutover checklist completed
- [ ] DNS updated (if using custom domain)
- [ ] Application verified on Azure
- [ ] Monitoring dashboards active
- [ ] AWS resources kept for 7-14 day validation period
- [ ] AWS infrastructure destroyed (after validation)
- [ ] Documentation updated
- [ ] Team trained on Azure infrastructure
```

---

**Document Version:** 1.0  
**Last Updated:** [Current Date]  
**Author:** Migration Team  
**Review Status:** Draft

