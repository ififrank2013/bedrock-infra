# CI/CD-specific Terraform variables
# This file is used by GitHub Actions workflows

# Note: k8s_rbac module will fail on destroy/patch operations in CI/CD due to 
# bedrock-dev-view user lacking EKS admin permissions. This is expected and safe.
# Core infrastructure changes (RDS, EKS, VPC, IAM) will be applied successfully.
enable_k8s_rbac = true  # Keep enabled for proper state management
