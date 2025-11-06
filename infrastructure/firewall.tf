# Firewall rule to allow Cloud Run VPC connector to access Cloud SQL
resource "google_compute_firewall" "cloudrun_to_cloudsql" {
  name    = "${local.name_prefix}-cloudrun-to-cloudsql"
  network = google_compute_network.main.name

  allow {
    protocol = "tcp"
    ports    = ["5432"]
  }

  source_ranges = [google_vpc_access_connector.main.ip_cidr_range]
  target_tags  = ["cloudsql"]

  description = "Allow Cloud Run VPC connector to access Cloud SQL on port 5432"

  labels = local.common_labels
}

# Note: Cloud Run services are automatically accessible via HTTPS
# No need for explicit ingress rules for Cloud Run
# Cloud SQL uses private IP and is accessed via VPC connector
# Firewall rules are simpler in GCP - they're network-level, not resource-level

