# CI/CD-specific Terraform variables
# This file is used by GitHub Actions workflows to disable admin-only features

enable_k8s_rbac = false  # RBAC management requires EKS admin credentials, disabled in CI/CD
