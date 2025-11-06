# Cloud Logging Log Sink (optional - Cloud Run automatically logs to Cloud Logging)
# Cloud Run services automatically send logs to Cloud Logging
# No explicit log group creation needed like CloudWatch

# Log-based metric for error tracking
resource "google_logging_metric" "error_count" {
  name   = "${local.name_prefix}-error-count"
  filter = "resource.type=cloud_run_revision AND severity>=ERROR"
  
  metric_descriptor {
    metric_kind = "DELTA"
    value_type  = "INT64"
    
    labels {
      key         = "service"
      value_type  = "STRING"
      description = "Cloud Run service name"
    }
  }

  label_extractors = {
    "service" = "EXTRACT(resource.labels.service_name)"
  }
}

# Log retention policy (via organization policy or project-level)
# Note: Default log retention is 30 days for Cloud Run
# For longer retention, configure at project level or use log exports

# Cloud KMS Key for log encryption (optional but recommended)
resource "google_kms_key_ring" "logging" {
  name     = "${local.name_prefix}-logging-keyring"
  location = var.gcp_region
}

resource "google_kms_crypto_key" "logging" {
  name            = "${local.name_prefix}-logging-key"
  key_ring        = google_kms_key_ring.logging.id
  rotation_period = "7776000s"  # 90 days

  purpose = "ENCRYPT_DECRYPT"
}

# Note: Cloud Logging automatically encrypts logs at rest
# KMS key is for additional encryption if needed
# Cloud Run logs are automatically sent to Cloud Logging with 30-day retention

