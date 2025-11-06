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
    gsutil lifecycle set - <<EOF gs://$BUCKET_NAME
{
  "rule": [
    {
      "action": {"type": "Delete"},
      "condition": {"age": 90}
    }
  ]
}
EOF
    echo "✅ GCS bucket created with versioning enabled"
fi
echo ""

# Create service account for Cloud Run
echo "👤 Creating service account for Cloud Run..."
SA_NAME="todoapp-cloudrun-sa"
SA_EMAIL="${SA_NAME}@${GCP_PROJECT_ID}.iam.gserviceaccount.com"

if gcloud iam service-accounts describe $SA_EMAIL --project=$GCP_PROJECT_ID &> /dev/null; then
    echo "⚠️  Service account already exists"
else
    gcloud iam service-accounts create $SA_NAME \
        --display-name="Todo App Cloud Run Service Account" \
        --description="Service account for Todo App Cloud Run services" \
        --project=$GCP_PROJECT_ID
    echo "✅ Service account created"
fi

# Grant necessary permissions
echo "🔐 Granting permissions to service account..."
gcloud projects add-iam-policy-binding $GCP_PROJECT_ID \
    --member="serviceAccount:${SA_EMAIL}" \
    --role="roles/secretmanager.secretAccessor" \
    --condition=None

gcloud projects add-iam-policy-binding $GCP_PROJECT_ID \
    --member="serviceAccount:${SA_EMAIL}" \
    --role="roles/logging.logWriter" \
    --condition=None

gcloud projects add-iam-policy-binding $GCP_PROJECT_ID \
    --member="serviceAccount:${SA_EMAIL}" \
    --role="roles/cloudsql.client" \
    --condition=None

echo "✅ Permissions granted"
echo ""

# Create service account for Cloud SQL
echo "👤 Creating service account for Cloud SQL..."
SQL_SA_NAME="todoapp-cloudsql-sa"
SQL_SA_EMAIL="${SQL_SA_NAME}@${GCP_PROJECT_ID}.iam.gserviceaccount.com"

if gcloud iam service-accounts describe $SQL_SA_EMAIL --project=$GCP_PROJECT_ID &> /dev/null; then
    echo "⚠️  Cloud SQL service account already exists"
else
    gcloud iam service-accounts create $SQL_SA_NAME \
        --display-name="Todo App Cloud SQL Service Account" \
        --description="Service account for Todo App Cloud SQL instance" \
        --project=$GCP_PROJECT_ID
    echo "✅ Cloud SQL service account created"
fi
echo ""

echo "🎉 GCP setup complete!"
echo ""
echo "📝 Next steps:"
echo "   1. Update infrastructure/main.tf with your GCP project ID: $GCP_PROJECT_ID"
echo "   2. Update infrastructure/main.tf with your GCS bucket: $BUCKET_NAME"
echo "   3. Run 'terraform init' in the infrastructure directory"
echo "   4. Run 'terraform plan' to review the infrastructure"
echo "   5. Run 'terraform apply' to deploy"

