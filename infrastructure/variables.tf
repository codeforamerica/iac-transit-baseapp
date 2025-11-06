variable "gcp_project_id" {
  description = "GCP project ID"
  type        = string
}

variable "gcp_region" {
  description = "GCP region"
  type        = string
  default     = "us-central1"
}

variable "gcp_zone" {
  description = "GCP zone"
  type        = string
  default     = "us-central1-a"
}

variable "project_name" {
  description = "Name of the project"
  type        = string
  default     = "todoapp"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "dev"
}

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks for private subnets"
  type        = list(string)
  default     = ["10.0.10.0/24", "10.0.20.0/24"]
}

variable "db_tier" {
  description = "Cloud SQL instance tier"
  type        = string
  default     = "db-f1-micro"
}

variable "db_disk_size" {
  description = "Cloud SQL disk size in GB"
  type        = number
  default     = 20
}

variable "db_disk_autoresize" {
  description = "Enable automatic disk resizing"
  type        = bool
  default     = true
}

variable "db_max_disk_size" {
  description = "Cloud SQL maximum disk size in GB"
  type        = number
  default     = 100
}

variable "db_username" {
  description = "Cloud SQL master username"
  type        = string
  default     = "todoapp_user"
}

variable "db_password" {
  description = "Cloud SQL master password"
  type        = string
  sensitive   = true
}

variable "db_name" {
  description = "Cloud SQL database name"
  type        = string
  default     = "todoapp"
}

variable "cloudrun_cpu" {
  description = "Cloud Run CPU allocation (number of CPUs, e.g., 1, 2, 4)"
  type        = string
  default     = "1"
}

variable "cloudrun_memory" {
  description = "Cloud Run memory allocation (e.g., 512Mi, 1Gi, 2Gi)"
  type        = string
  default     = "512Mi"
}

variable "cloudrun_min_instances" {
  description = "Cloud Run minimum number of instances"
  type        = number
  default     = 0
}

variable "cloudrun_max_instances" {
  description = "Cloud Run maximum number of instances"
  type        = number
  default     = 10
}

variable "container_port" {
  description = "Container port"
  type        = number
  default     = 3001
}

variable "frontend_port" {
  description = "Frontend container port"
  type        = number
  default     = 3000
}

variable "secret_manager_secret_name" {
  description = "Secret Manager secret name"
  type        = string
  default     = ""  # Will be set dynamically based on environment and project
}

variable "domain_name" {
  description = "Domain name for the application (optional)"
  type        = string
  default     = ""
}

variable "artifact_registry_repo" {
  description = "Artifact Registry repository name"
  type        = string
  default     = "todoapp-repo"
}

variable "artifact_registry_location" {
  description = "Artifact Registry location"
  type        = string
  default     = "us-central1"
}
