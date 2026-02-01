#!/bin/bash

# Cleanup Script - Destroys all infrastructure
# WARNING: This will delete all resources created by Terraform

set -e

echo "================================================"
echo "⚠️  WARNING: Infrastructure Cleanup"
echo "================================================"
echo ""
echo "This script will destroy ALL infrastructure resources."
echo "This action CANNOT be undone!"
echo ""
read -p "Are you sure you want to continue? (type 'yes' to confirm): " confirm

if [ "$confirm" != "yes" ]; then
    echo "Cleanup cancelled."
    exit 0
fi

echo ""
echo "🗑️  Starting cleanup process..."
echo ""

# Configuration
CLUSTER_NAME="project-bedrock-cluster"
AWS_REGION="us-east-1"
NAMESPACE="retail-app"
BACKEND_BUCKET="bedrock-terraform-state-alt-soe-025-0275"
DYNAMODB_TABLE="bedrock-terraform-locks"

# Delete Kubernetes resources first
echo "🧹 Cleaning up Kubernetes resources..."
kubectl delete namespace $NAMESPACE --ignore-not-found=true --wait=true

# Wait for LoadBalancers to be deleted
echo "⏳ Waiting for LoadBalancers to be cleaned up..."
sleep 60

# Run Terraform destroy
echo "🔥 Destroying Terraform infrastructure..."
cd ../terraform
terraform destroy -auto-approve

echo ""
echo "🧹 Cleaning up backend resources..."
echo ""

# Empty and delete S3 bucket
echo "📦 Emptying S3 bucket..."
aws s3 rm s3://$BACKEND_BUCKET --recursive 2>/dev/null || true

echo "🗑️  Deleting S3 bucket..."
aws s3api delete-bucket --bucket $BACKEND_BUCKET --region $AWS_REGION 2>/dev/null || true

# Delete DynamoDB table
echo "🗄️  Deleting DynamoDB table..."
aws dynamodb delete-table --table-name $DYNAMODB_TABLE --region $AWS_REGION 2>/dev/null || true

echo ""
echo "✅ Cleanup complete!"
echo ""
