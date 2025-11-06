#!/bin/bash

# Destruction script for GCP resources
set -e

echo "🗑️  Destroying Todo App infrastructure..."

# Check if Terraform is installed
if ! command -v terraform &> /dev/null; then
    echo "❌ Terraform is not installed. Please install Terraform and try again."
    exit 1
fi

# Navigate to infrastructure directory
cd infrastructure

# Check if Terraform state exists
if [ ! -f "terraform.tfstate" ] && [ ! -f ".terraform/terraform.tfstate" ]; then
    echo "⚠️  No Terraform state found. Nothing to destroy."
    echo "📝 If resources exist in GCP but state is missing, use GCP Console to delete manually."
    exit 0
fi

# Destroy infrastructure
echo "📋 Planning destruction..."
terraform plan -destroy

echo ""
echo "⚠️  WARNING: This will destroy all GCP resources!"
read -p "Are you sure you want to continue? (yes/no): " -r
echo

if [[ $REPLY =~ ^[Yy][Ee][Ss]$ ]]; then
    echo "🚀 Destroying infrastructure..."
    terraform destroy -auto-approve
    
    echo ""
    echo "✅ Infrastructure destroyed successfully!"
    echo ""
    echo "📝 Note: Cloud Logging logs are retained for 30 days by default."
    echo "📝 Note: Cloud SQL backups are retained according to backup configuration."
else
    echo "❌ Destruction cancelled."
    exit 1
fi

echo ""
echo "🎉 Cleanup complete!"
