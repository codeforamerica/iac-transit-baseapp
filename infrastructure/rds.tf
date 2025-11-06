# Note: Private IP for Cloud SQL requires Service Networking API permissions
# For testing, we'll use public IP with authorized networks
# To use private IP later, you'll need to:
# 1. Have Service Networking Admin role
# 2. Uncomment the private IP configuration below
# 3. Set up VPC peering connection manually or with proper permissions

# Private Service Connection for Cloud SQL (commented out - requires permissions)
# resource "google_compute_global_address" "private_ip_address" {
#   name          = "${local.name_prefix}-private-ip"
#   purpose       = "VPC_PEERING"
#   address_type  = "INTERNAL"
#   prefix_length = 16
#   network       = google_compute_network.main.id
# }
# 
# resource "google_service_networking_connection" "private_vpc_connection" {
#   network                 = google_compute_network.main.id
#   service                 = "servicenetworking.googleapis.com"
#   reserved_peering_ranges = [google_compute_global_address.private_ip_address.name]
# }

# Cloud SQL Instance
resource "google_sql_database_instance" "main" {
  name             = "${local.name_prefix}-db"
  database_version = "POSTGRES_15"
  region           = var.gcp_region

  settings {
    tier                        = var.db_tier
    disk_type                   = "PD_SSD"
    disk_size                   = var.db_disk_size
    disk_autoresize             = var.db_disk_autoresize
    disk_autoresize_limit       = var.db_max_disk_size
    availability_type           = "ZONAL"
    deletion_protection_enabled  = var.environment == "prod" ? true : false

    # Backup configuration
    backup_configuration {
      enabled                        = true
      start_time                     = "03:00"
      point_in_time_recovery_enabled = true
      transaction_log_retention_days = 7
      backup_retention_settings {
        retained_backups = 31
        retention_unit   = "COUNT"
      }
    }

    # Maintenance window
    maintenance_window {
      day          = 7  # Sunday
      hour         = 4
      update_track = "stable"
    }

    # Database flags
    database_flags {
      name  = "log_checkpoints"
      value = "on"
    }
    database_flags {
      name  = "log_connections"
      value = "on"
    }
    database_flags {
      name  = "log_disconnections"
      value = "on"
    }

    # IP configuration - use public IP for testing (can be changed to private IP later)
    ip_configuration {
      ipv4_enabled    = true
      ssl_mode        = "ENCRYPTED_ONLY"
      # Allow access from Cloud Run (0.0.0.0/0 is permissive - restrict in production)
      authorized_networks {
        value = "0.0.0.0/0"
        name  = "cloud-run-access"
      }
    }

    # Insights configuration (similar to Performance Insights)
    insights_config {
      query_insights_enabled  = true
      query_string_length      = 1024
      record_application_tags   = true
      record_client_address     = true
    }
  }

  # Deletion protection
  deletion_protection = var.environment == "prod" ? true : false
}

# Cloud SQL Database
resource "google_sql_database" "main" {
  name     = var.db_name
  instance = google_sql_database_instance.main.name
}

# Cloud SQL User
resource "google_sql_user" "main" {
  name     = var.db_username
  instance = google_sql_database_instance.main.name
  password = var.db_password
}
