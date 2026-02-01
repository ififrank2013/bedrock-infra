# Setup Script for Project Bedrock Infrastructure (PowerShell Version)
# This script initializes the Terraform backend and sets up the remote state

$ErrorActionPreference = "Stop"

Write-Host "================================================" -ForegroundColor Cyan
Write-Host "Project Bedrock - Infrastructure Setup" -ForegroundColor Cyan
Write-Host "================================================" -ForegroundColor Cyan
Write-Host ""

# Configuration
$AWS_REGION = "us-east-1"
$BACKEND_BUCKET = "bedrock-terraform-state-alt-soe-025-0275"
$DYNAMODB_TABLE = "bedrock-terraform-locks"
$STUDENT_ID = "ALT-SOE-025-0275"

Write-Host "📦 Creating S3 bucket for Terraform state..." -ForegroundColor Yellow
try {
    if ($AWS_REGION -eq "us-east-1") {
        aws s3api create-bucket --bucket $BACKEND_BUCKET --region $AWS_REGION 2>$null
    } else {
        aws s3api create-bucket --bucket $BACKEND_BUCKET --region $AWS_REGION --create-bucket-configuration LocationConstraint=$AWS_REGION 2>$null
    }
    Write-Host "✅ Bucket created successfully" -ForegroundColor Green
} catch {
    Write-Host "ℹ️  Bucket already exists" -ForegroundColor Gray
}

Write-Host "🔒 Enabling versioning on S3 bucket..." -ForegroundColor Yellow
aws s3api put-bucket-versioning --bucket $BACKEND_BUCKET --versioning-configuration Status=Enabled

Write-Host "🔐 Enabling encryption on S3 bucket..." -ForegroundColor Yellow
$encryptionConfig = @'
{
    "Rules": [{
        "ApplyServerSideEncryptionByDefault": {
            "SSEAlgorithm": "AES256"
        }
    }]
}
'@
aws s3api put-bucket-encryption --bucket $BACKEND_BUCKET --server-side-encryption-configuration $encryptionConfig

Write-Host "🚫 Blocking public access to S3 bucket..." -ForegroundColor Yellow
aws s3api put-public-access-block `
    --bucket $BACKEND_BUCKET `
    --public-access-block-configuration "BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true"

Write-Host "🏷️  Tagging S3 bucket..." -ForegroundColor Yellow
aws s3api put-bucket-tagging `
    --bucket $BACKEND_BUCKET `
    --tagging "TagSet=[{Key=Project,Value=barakat-2025-capstone},{Key=ManagedBy,Value=Terraform},{Key=StudentID,Value=$STUDENT_ID}]"

Write-Host "🗄️  Creating DynamoDB table for state locking..." -ForegroundColor Yellow
try {
    aws dynamodb create-table `
        --table-name $DYNAMODB_TABLE `
        --attribute-definitions AttributeName=LockID,AttributeType=S `
        --key-schema AttributeName=LockID,KeyType=HASH `
        --provisioned-throughput ReadCapacityUnits=5,WriteCapacityUnits=5 `
        --region $AWS_REGION `
        --tags "Key=Project,Value=barakat-2025-capstone" "Key=ManagedBy,Value=Terraform" "Key=StudentID,Value=$STUDENT_ID" 2>$null
    Write-Host "✅ DynamoDB table created successfully" -ForegroundColor Green
} catch {
    Write-Host "ℹ️  DynamoDB table already exists" -ForegroundColor Gray
}

Write-Host ""
Write-Host "✅ Backend setup complete!" -ForegroundColor Green
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Cyan
Write-Host "1. cd terraform" -ForegroundColor White
Write-Host "2. terraform init" -ForegroundColor White
Write-Host "3. terraform plan" -ForegroundColor White
Write-Host "4. terraform apply" -ForegroundColor White
Write-Host ""
