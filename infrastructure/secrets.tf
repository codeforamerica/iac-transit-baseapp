# Secret Manager Secret with unique name
resource "google_secret_manager_secret" "main" {
  secret_id = var.secret_manager_secret_name != "" ? var.secret_manager_secret_name : "${local.name_prefix}-db-secret-${data.google_project.current.project_id}-${formatdate("YYYY-MM-DD-hhmm", timestamp())}"
  
  replication {
    auto {}
  }

  labels = local.common_labels
}

# Secret Manager Secret Version
resource "google_secret_manager_secret_version" "main" {
  secret = google_secret_manager_secret.main.id
  
  secret_data = jsonencode({
    db_host     = google_sql_database_instance.main.private_ip_address
    db_port     = "5432"
    db_name     = google_sql_database.main.name
    db_user     = google_sql_user.main.name
    db_password = google_sql_user.main.password
  })
}
