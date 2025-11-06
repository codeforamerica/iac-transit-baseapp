# VPC Network
resource "google_compute_network" "main" {
  name                    = "${local.name_prefix}-vpc"
  auto_create_subnetworks = false
  routing_mode            = "REGIONAL"
}

# Public Subnets
resource "google_compute_subnetwork" "public" {
  count = length(var.public_subnet_cidrs)

  name          = "${local.name_prefix}-public-subnet-${count.index + 1}"
  ip_cidr_range = var.public_subnet_cidrs[count.index]
  region        = var.gcp_region
  network       = google_compute_network.main.id

  # Enable private Google access for Cloud Run VPC connector
  private_ip_google_access = true

  # VPC Flow Logs
  log_config {
    aggregation_interval = "INTERVAL_5_SEC"
    flow_sampling        = 0.5
    metadata            = "INCLUDE_ALL_METADATA"
  }
}

# Private Subnets
resource "google_compute_subnetwork" "private" {
  count = length(var.private_subnet_cidrs)

  name          = "${local.name_prefix}-private-subnet-${count.index + 1}"
  ip_cidr_range = var.private_subnet_cidrs[count.index]
  region        = var.gcp_region
  network       = google_compute_network.main.id

  # Enable private Google access for Cloud SQL
  private_ip_google_access = true

  # VPC Flow Logs
  log_config {
    aggregation_interval = "INTERVAL_5_SEC"
    flow_sampling        = 0.5
    metadata            = "INCLUDE_ALL_METADATA"
  }
}

# VPC Connector for Cloud Run to access private resources (Cloud SQL)
# Commented out - not needed when using public IP for Cloud SQL
# Uncomment if you set up private IP for Cloud SQL
# resource "google_vpc_access_connector" "main" {
#   name          = "mp-todoapp-vpc-conn"  # Shortened to meet naming requirements
#   region        = var.gcp_region
#   network       = google_compute_network.main.name
#   ip_cidr_range = "10.8.0.0/28"  # Small CIDR for connector
#
#   min_instances = 2
#   max_instances = 3
#   machine_type  = "e2-micro"
# }

# Note: GCP VPC networking is simpler than AWS
# - No need for Internet Gateway (automatic)
# - No need for route tables (automatic routing)
# - Subnets are regional, not zonal
# - Cloud Run can use VPC connector for private IP access
