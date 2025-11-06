output "vpc_network_id" {
  description = "ID of the VPC network"
  value       = google_compute_network.main.id
}

output "vpc_network_name" {
  description = "Name of the VPC network"
  value       = google_compute_network.main.name
}

output "public_subnet_ids" {
  description = "IDs of the public subnets"
  value       = google_compute_subnetwork.public[*].id
}

output "private_subnet_ids" {
  description = "IDs of the private subnets"
  value       = google_compute_subnetwork.private[*].id
}

output "cloud_sql_connection_name" {
  description = "Cloud SQL instance connection name"
  value       = google_sql_database_instance.main.connection_name
}

output "cloud_sql_public_ip" {
  description = "Cloud SQL instance public IP address"
  value       = google_sql_database_instance.main.public_ip_address
  sensitive   = true
}

output "cloud_sql_port" {
  description = "Cloud SQL instance port"
  value       = "5432"
}

output "backend_service_url" {
  description = "Backend Cloud Run service URL"
  value       = google_cloud_run_service.backend.status[0].url
}

output "frontend_service_url" {
  description = "Frontend Cloud Run service URL"
  value       = google_cloud_run_service.frontend.status[0].url
}

output "secret_manager_secret_id" {
  description = "Secret Manager secret ID"
  value       = google_secret_manager_secret.main.secret_id
}

output "artifact_registry_backend" {
  description = "Backend Artifact Registry repository URL"
  value       = "${var.artifact_registry_location}-docker.pkg.dev/${var.gcp_project_id}/${google_artifact_registry_repository.backend.repository_id}"
}

output "artifact_registry_frontend" {
  description = "Frontend Artifact Registry repository URL"
  value       = "${var.artifact_registry_location}-docker.pkg.dev/${var.gcp_project_id}/${google_artifact_registry_repository.frontend.repository_id}"
}

output "application_url" {
  description = "Application URL (Frontend Cloud Run service)"
  value       = google_cloud_run_service.frontend.status[0].url
}
