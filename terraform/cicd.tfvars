# CI/CD-specific Terraform variables
# This file is used by GitHub Actions workflows

# Disable k8s_rbac module in CI/CD: bedrock-dev-view user cannot manage RBAC resources.
# RBAC resources should be managed separately with admin credentials.
enable_k8s_rbac = false
