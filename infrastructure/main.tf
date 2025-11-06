terraform {
  required_version = ">= 1.0"
  
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }

  backend "gcs" {
    bucket = "iac-transit-terraform-state-se-discovery-iac-translation"
    prefix = "todoapp/terraform.tfstate"
  }
}

provider "google" {
  project = var.gcp_project_id
  region  = var.gcp_region
}

# Data sources
data "google_project" "current" {}

data "google_client_config" "current" {}

# Local values
locals {
  name_prefix = "mp-${var.project_name}-${var.environment}"
  
  common_labels = {
    project     = var.project_name
    environment = var.environment
    managed_by  = "terraform"
  }
}
