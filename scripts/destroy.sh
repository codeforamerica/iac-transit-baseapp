#!/bin/bash

# Destruction script for AWS resources
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
    echo "📝 If resources exist in AWS but state is missing, use AWS Console to delete manually."
    exit 0
fi

# Destroy infrastructure
echo "📋 Planning destruction..."
terraform plan -destroy

echo ""
echo "⚠️  WARNING: This will destroy all AWS resources!"
read -p "Are you sure you want to continue? (yes/no): " -r
echo

if [[ $REPLY =~ ^[Yy][Ee][Ss]$ ]]; then
    echo "🚀 Destroying infrastructure..."
    terraform destroy -auto-approve
    
    echo ""
    echo "✅ Infrastructure destroyed successfully!"
    echo ""
    echo "📝 Note: CloudWatch logs are retained for 30 days by default."
    echo "📝 Note: RDS final snapshot is created before deletion (check S3 for backups)."
else
    echo "❌ Destruction cancelled."
    exit 1
fi

echo ""
echo "🎉 Cleanup complete!"
