# Service Account for Cloud Run services
resource "google_service_account" "cloudrun" {
  account_id   = "${local.name_prefix}-cloudrun-sa"
  display_name = "Todo App Cloud Run Service Account"
  description  = "Service account for Todo App Cloud Run services"

  labels = local.common_labels
}

# IAM binding for Secret Manager access
resource "google_project_iam_member" "cloudrun_secret_accessor" {
  project = var.gcp_project_id
  role    = "roles/secretmanager.secretAccessor"
  member  = "serviceAccount:${google_service_account.cloudrun.email}"
}

# IAM binding for Cloud Logging
resource "google_project_iam_member" "cloudrun_log_writer" {
  project = var.gcp_project_id
  role    = "roles/logging.logWriter"
  member  = "serviceAccount:${google_service_account.cloudrun.email}"
}

# IAM binding for Cloud SQL client access
resource "google_project_iam_member" "cloudrun_sql_client" {
  project = var.gcp_project_id
  role    = "roles/cloudsql.client"
  member  = "serviceAccount:${google_service_account.cloudrun.email}"
}

# Service Account for Cloud SQL (if needed for monitoring)
resource "google_service_account" "cloudsql" {
  account_id   = "${local.name_prefix}-cloudsql-sa"
  display_name = "Todo App Cloud SQL Service Account"
  description  = "Service account for Todo App Cloud SQL instance"

  labels = local.common_labels
}

