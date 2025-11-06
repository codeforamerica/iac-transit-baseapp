# Service Account for Cloud Run services
resource "google_service_account" "cloudrun" {
  account_id   = "${local.name_prefix}-cloudrun-sa"
  display_name = "Todo App Cloud Run Service Account"
  description  = "Service account for Todo App Cloud Run services"
}

# IAM bindings for service account (commented out - requires Project IAM Admin role)
# These need to be set up manually if you don't have permissions:
# 
# gcloud projects add-iam-policy-binding ${var.gcp_project_id} \
#   --member="serviceAccount:${google_service_account.cloudrun.email}" \
#   --role="roles/secretmanager.secretAccessor"
#
# gcloud projects add-iam-policy-binding ${var.gcp_project_id} \
#   --member="serviceAccount:${google_service_account.cloudrun.email}" \
#   --role="roles/logging.logWriter"
#
# gcloud projects add-iam-policy-binding ${var.gcp_project_id} \
#   --member="serviceAccount:${google_service_account.cloudrun.email}" \
#   --role="roles/cloudsql.client"

# Uncomment these if you have Project IAM Admin permissions:
# resource "google_project_iam_member" "cloudrun_secret_accessor" {
#   project = var.gcp_project_id
#   role    = "roles/secretmanager.secretAccessor"
#   member  = "serviceAccount:${google_service_account.cloudrun.email}"
# }
#
# resource "google_project_iam_member" "cloudrun_log_writer" {
#   project = var.gcp_project_id
#   role    = "roles/logging.logWriter"
#   member  = "serviceAccount:${google_service_account.cloudrun.email}"
# }
#
# resource "google_project_iam_member" "cloudrun_sql_client" {
#   project = var.gcp_project_id
#   role    = "roles/cloudsql.client"
#   member  = "serviceAccount:${google_service_account.cloudrun.email}"
# }

# Service Account for Cloud SQL (if needed for monitoring)
resource "google_service_account" "cloudsql" {
  account_id   = "${local.name_prefix}-cloudsql-sa"
  display_name = "Todo App Cloud SQL Service Account"
  description  = "Service account for Todo App Cloud SQL instance"
}

