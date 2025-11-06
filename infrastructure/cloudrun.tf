# Artifact Registry Repository for Backend
resource "google_artifact_registry_repository" "backend" {
  location      = var.artifact_registry_location
  repository_id = "${local.name_prefix}-backend"
  description   = "Docker repository for Todo App backend"
  format        = "DOCKER"

  labels = local.common_labels
}

# Artifact Registry Repository for Frontend
resource "google_artifact_registry_repository" "frontend" {
  location      = var.artifact_registry_location
  repository_id = "${local.name_prefix}-frontend"
  description   = "Docker repository for Todo App frontend"
  format        = "DOCKER"

  labels = local.common_labels
}

# Cloud Run Service for Backend
resource "google_cloud_run_service" "backend" {
  name     = "${local.name_prefix}-backend"
  location = var.gcp_region

  template {
    spec {
      service_account_name = google_service_account.cloudrun.email
      
      containers {
        image = "${var.artifact_registry_location}-docker.pkg.dev/${var.gcp_project_id}/${google_artifact_registry_repository.backend.repository_id}/backend:latest"
        
        ports {
          container_port = var.container_port
        }

        env {
          name  = "NODE_ENV"
          value = "production"
        }
        env {
          name  = "API_PORT"
          value = tostring(var.container_port)
        }
        env {
          name  = "GCP_PROJECT_ID"
          value = var.gcp_project_id
        }
        env {
          name  = "SECRET_MANAGER_SECRET_NAME"
          value = google_secret_manager_secret.main.secret_id
        }
        env {
          name  = "DB_HOST"
          value = google_sql_database_instance.main.private_ip_address
        }
        env {
          name  = "DB_PORT"
          value = "5432"
        }
        env {
          name  = "DB_NAME"
          value = google_sql_database.main.name
        }
        env {
          name  = "DB_USER"
          value = google_sql_user.main.name
        }

        resources {
          limits = {
            cpu    = var.cloudrun_cpu
            memory = var.cloudrun_memory
          }
        }

        startup_probe {
          http_get {
            path = "/api/health"
          }
          initial_delay_seconds = 0
          timeout_seconds       = 1
          period_seconds        = 3
          failure_threshold     = 3
        }

        liveness_probe {
          http_get {
            path = "/api/health"
          }
          initial_delay_seconds = 0
          timeout_seconds       = 1
          period_seconds        = 3
          failure_threshold     = 3
        }
      }

      container_concurrency = 80
      timeout_seconds       = 300
    }

    metadata {
      annotations = {
        "autoscaling.knative.dev/minScale" = tostring(var.cloudrun_min_instances)
        "autoscaling.knative.dev/maxScale" = tostring(var.cloudrun_max_instances)
        "run.googleapis.com/vpc-access-connector" = google_vpc_access_connector.main.name
        "run.googleapis.com/vpc-access-egress"    = "private-ranges-only"
      }
      labels = local.common_labels
    }
  }

  traffic {
    percent         = 100
    latest_revision = true
  }

  labels = local.common_labels

  depends_on = [
    google_service_account.cloudrun,
    google_vpc_access_connector.main,
    google_sql_database_instance.main
  ]
}

# Cloud Run Service for Frontend
resource "google_cloud_run_service" "frontend" {
  name     = "${local.name_prefix}-frontend"
  location = var.gcp_region

  template {
    spec {
      service_account_name = google_service_account.cloudrun.email
      
      containers {
        image = "${var.artifact_registry_location}-docker.pkg.dev/${var.gcp_project_id}/${google_artifact_registry_repository.frontend.repository_id}/frontend:latest"
        
        ports {
          container_port = var.frontend_port
        }

        env {
          name  = "CLOUD_RUN_URL"
          value = google_cloud_run_service.backend.status[0].url
        }

        resources {
          limits = {
            cpu    = var.cloudrun_cpu
            memory = var.cloudrun_memory
          }
        }

        startup_probe {
          http_get {
            path = "/"
          }
          initial_delay_seconds = 0
          timeout_seconds       = 1
          period_seconds        = 3
          failure_threshold     = 3
        }

        liveness_probe {
          http_get {
            path = "/"
          }
          initial_delay_seconds = 0
          timeout_seconds       = 1
          period_seconds        = 3
          failure_threshold     = 3
        }
      }

      container_concurrency = 80
      timeout_seconds       = 300
    }

    metadata {
      annotations = {
        "autoscaling.knative.dev/minScale" = tostring(var.cloudrun_min_instances)
        "autoscaling.knative.dev/maxScale" = tostring(var.cloudrun_max_instances)
      }
      labels = local.common_labels
    }
  }

  traffic {
    percent         = 100
    latest_revision = true
  }

  labels = local.common_labels

  depends_on = [
    google_service_account.cloudrun,
    google_cloud_run_service.backend
  ]
}

# IAM policy to allow unauthenticated access to Cloud Run services
resource "google_cloud_run_service_iam_member" "backend_public" {
  service  = google_cloud_run_service.backend.name
  location = google_cloud_run_service.backend.location
  role     = "roles/run.invoker"
  member   = "allUsers"
}

resource "google_cloud_run_service_iam_member" "frontend_public" {
  service  = google_cloud_run_service.frontend.name
  location = google_cloud_run_service.frontend.location
  role     = "roles/run.invoker"
  member   = "allUsers"
}

