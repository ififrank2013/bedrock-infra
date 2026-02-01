#!/bin/bash

# Setup Script for Project Bedrock Infrastructure
# This script initializes the Terraform backend and sets up the remote state

set -e

echo "================================================"
echo "Project Bedrock - Infrastructure Setup"
echo "================================================"
echo ""

# Configuration
AWS_REGION="us-east-1"
BACKEND_BUCKET="bedrock-terraform-state-alt-soe-025-0275"
DYNAMODB_TABLE="bedrock-terraform-locks"
STUDENT_ID="ALT-SOE-025-0275"

echo "📦 Creating S3 bucket for Terraform state..."
if [ "$AWS_REGION" = "us-east-1" ]; then
    aws s3api create-bucket \
        --bucket $BACKEND_BUCKET \
        --region $AWS_REGION 2>/dev/null || echo "Bucket already exists"
else
    aws s3api create-bucket \
        --bucket $BACKEND_BUCKET \
        --region $AWS_REGION \
        --create-bucket-configuration LocationConstraint=$AWS_REGION 2>/dev/null || echo "Bucket already exists"
fi

echo "🔒 Enabling versioning on S3 bucket..."
aws s3api put-bucket-versioning \
    --bucket $BACKEND_BUCKET \
    --versioning-configuration Status=Enabled

echo "🔐 Enabling encryption on S3 bucket..."
aws s3api put-bucket-encryption \
    --bucket $BACKEND_BUCKET \
    --server-side-encryption-configuration '{
        "Rules": [{
            "ApplyServerSideEncryptionByDefault": {
                "SSEAlgorithm": "AES256"
            }
        }]
    }'

echo "🚫 Blocking public access to S3 bucket..."
aws s3api put-public-access-block \
    --bucket $BACKEND_BUCKET \
    --public-access-block-configuration \
        BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true

echo "🏷️  Tagging S3 bucket..."
aws s3api put-bucket-tagging \
    --bucket $BACKEND_BUCKET \
    --tagging "TagSet=[{Key=Project,Value=barakat-2025-capstone},{Key=ManagedBy,Value=Terraform},{Key=StudentID,Value=$STUDENT_ID}]"

echo "🗄️  Creating DynamoDB table for state locking..."
aws dynamodb create-table \
    --table-name $DYNAMODB_TABLE \
    --attribute-definitions AttributeName=LockID,AttributeType=S \
    --key-schema AttributeName=LockID,KeyType=HASH \
    --provisioned-throughput ReadCapacityUnits=5,WriteCapacityUnits=5 \
    --region $AWS_REGION \
    --tags Key=Project,Value=barakat-2025-capstone Key=ManagedBy,Value=Terraform Key=StudentID,Value=$STUDENT_ID \
    2>/dev/null || echo "DynamoDB table already exists"

echo ""
echo "✅ Backend setup complete!"
echo ""
echo "Next steps:"
echo "1. cd terraform"
echo "2. terraform init"
echo "3. terraform plan"
echo "4. terraform apply"
echo ""
