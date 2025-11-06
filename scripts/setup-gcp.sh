#!/bin/bash

# Script to set up GCP project for Todo App deployment
set -e

echo "🔧 Setting up GCP project for Todo App..."

# Check if gcloud CLI is installed
if ! command -v gcloud &> /dev/null; then
    echo "❌ gcloud CLI is not installed. Please install Google Cloud SDK and try again."
    exit 1
fi

# Check if user is authenticated
if ! gcloud auth list --filter=status:ACTIVE --format="value(account)" &> /dev/null; then
    echo "❌ No active gcloud authentication found. Please run 'gcloud auth login' and try again."
    exit 1
fi

# Get GCP project ID
GCP_PROJECT_ID=$(gcloud config get-value project 2>/dev/null)
if [ -z "$GCP_PROJECT_ID" ]; then
    echo "❌ No GCP project is set. Please set a project with 'gcloud config set project PROJECT_ID'"
    exit 1
fi

echo "📋 Configuration:"
echo "   GCP Project ID: $GCP_PROJECT_ID"
echo ""

# Enable required APIs
echo "🔌 Enabling required GCP APIs..."
gcloud services enable \
    run.googleapis.com \
    sqladmin.googleapis.com \
    secretmanager.googleapis.com \
    artifactregistry.googleapis.com \
    logging.googleapis.com \
    compute.googleapis.com \
    vpcaccess.googleapis.com \
    servicenetworking.googleapis.com \
    --project=$GCP_PROJECT_ID

echo "✅ APIs enabled"
echo ""

# Create Artifact Registry repository
echo "📦 Creating Artifact Registry repository..."
REPO_NAME="todoapp-repo"
REPO_LOCATION="us-central1"

if gcloud artifacts repositories describe $REPO_NAME --location=$REPO_LOCATION --project=$GCP_PROJECT_ID &> /dev/null; then
    echo "⚠️  Artifact Registry repository already exists"
else
    gcloud artifacts repositories create $REPO_NAME \
        --repository-format=docker \
        --location=$REPO_LOCATION \
        --description="Docker repository for Todo App" \
        --project=$GCP_PROJECT_ID
    echo "✅ Artifact Registry repository created"
fi
echo ""

# Create GCS bucket for Terraform state
echo "🗄️  Creating GCS bucket for Terraform state..."
BUCKET_NAME="iac-transit-terraform-state-${GCP_PROJECT_ID}"

if gsutil ls -b gs://$BUCKET_NAME &> /dev/null; then
    echo "⚠️  GCS bucket already exists"
else
    gsutil mb -p $GCP_PROJECT_ID -c STANDARD -l $REPO_LOCATION gs://$BUCKET_NAME
    gsutil versioning set on gs://$BUCKET_NAME
    # Set lifecycle policy using a temporary file
    LIFECYCLE_TMP=$(mktemp)
    cat > "$LIFECYCLE_TMP" <<EOF
{
  "rule": [
    {
      "action": {"type": "Delete"},
      "condition": {"age": 90}
    }
  ]
}
EOF
    gsutil lifecycle set "$LIFECYCLE_TMP" gs://$BUCKET_NAME
    rm -f "$LIFECYCLE_TMP"
    echo "✅ GCS bucket created with versioning enabled"
fi
echo ""

# Note: Service accounts and IAM bindings are managed by Terraform
# The service accounts created by Terraform will have the "mp" prefix
# (e.g., mp-todoapp-dev-cloudrun-sa) and all necessary permissions.
# 
# If you want to pre-create service accounts manually, you can do so,
# but Terraform will create its own with the proper naming convention.
echo "ℹ️  Service accounts and IAM permissions will be created by Terraform"
echo "   (Service accounts will be prefixed with 'mp' for uniqueness)"
echo ""

echo "🎉 GCP setup complete!"
echo ""
echo "📝 Next steps:"
echo "   1. Update infrastructure/main.tf with your GCP project ID: $GCP_PROJECT_ID"
echo "   2. Update infrastructure/main.tf with your GCS bucket: $BUCKET_NAME"
echo "   3. Run 'terraform init' in the infrastructure directory"
echo "   4. Run 'terraform plan' to review the infrastructure"
echo "   5. Run 'terraform apply' to deploy"

