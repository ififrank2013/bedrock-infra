# CI/CD Pipeline Guide

This guide explains how to trigger the GitHub Actions CI/CD pipeline for Project Bedrock infrastructure deployment.

## Pipeline Overview

The pipeline automatically deploys infrastructure changes using Terraform and manages the complete AWS EKS environment.

**Pipeline File**: `.github/workflows/terraform.yml`

## Automatic Triggers

The pipeline automatically runs when:

### 1. Push to Main Branch

Any push to the `main` branch that modifies infrastructure files will trigger the pipeline:

```bash
git add .
git commit -m "Update infrastructure configuration"
git push origin main
```

**Triggers on changes to**:
- `terraform/**` - Any Terraform configuration files
- `.github/workflows/terraform.yml` - Pipeline configuration
- `k8s/**` - Kubernetes manifests

### 2. Pull Request

When you create or update a pull request targeting the `main` branch:

```bash
git checkout -b feature/my-changes
git add .
git commit -m "Add new feature"
git push origin feature/my-changes
# Then create PR on GitHub
```

This runs a **plan-only** job that shows what changes will be made without applying them.


## Manual Trigger

The pipeline can also be manually trigger from the GitHub Actions interface:

### Steps:

1. **Navigate to Actions**
   - Go to: `https://github.com/ififrank2013/bedrock-infra/actions`

2. **Select Workflow**
   - Click on "Terraform CI/CD" in the left sidebar

3. **Run Workflow**
   - Click the "Run workflow" button (top right)
   - Select branch: `main`
   - Choose action:
     - `plan` - Preview changes without applying
     - `apply` - Apply infrastructure changes
   - Click "Run workflow" button

### Using GitHub CLI

If you have GitHub CLI installed:

```bash
# Trigger with plan action
gh workflow run "Terraform CI/CD" --ref main -f action=plan

# Trigger with apply action
gh workflow run "Terraform CI/CD" --ref main -f action=apply
```

## Pipeline Jobs

The pipeline consists of four main jobs:

### 1. Terraform Plan (PR only)
- Validates Terraform configuration
- Creates execution plan
- Shows proposed changes
- Adds comments to PR

### 2. Terraform Apply (Push to main or manual trigger)
- Imports existing resources
- Creates fresh plan
- Applies infrastructure changes
- Handles expected permission errors

### 3. Deploy Application
- Configures kubectl
- Deploys retail application using Helm
- Creates LoadBalancer service
- Verifies deployment

### 4. Validate Infrastructure (PR only)
- Checks EKS cluster health
- Verifies node group status
- Validates LoadBalancer
- Confirms RDS databases
- Tests S3 bucket access
- Checks Lambda function

## Monitoring Pipeline Execution

### View Logs

1. Go to Actions tab: `https://github.com/ififrank2013/bedrock-infra/actions`
2. Click on the workflow run you want to inspect
3. Click on individual jobs to see detailed logs
4. Expand steps to see command outputs

### Check Status

Pipeline status indicators:
- **Success**: Success
- **Yellow circle**: In progress
- **Red X**: Failed
- **Gray**: Skipped

### Pipeline Notifications

You'll receive notifications via:
- GitHub notifications (if enabled)
- Email (if configured in GitHub settings)
- Status checks on commits and PRs

## Expected Behavior

### On Pull Request
```
Terraform Plan completed
Validation checks passed
→ No infrastructure changes applied
→ Review plan in workflow logs
```

### On Push to Main
```
Terraform Apply executed
Application deployed
Infrastructure updated
→ Check outputs in workflow summary
```

### Manual Trigger with 'apply'
```
Manual approval step (10 second delay)
Resource import completed
Fresh plan created
Changes applied to AWS
```

## Troubleshooting

### Pipeline Fails

**Check logs**:
1. Go to failed workflow run
2. Identify which job failed
3. Read error messages in logs
4. Common issues:
   - AWS credentials expired
   - Terraform state lock
   - Resource permission errors

**Resolution**:
- For credential issues: Update GitHub Secrets
- For state locks: Wait or manually unlock
- For permissions: Expected for read-only user

### Pipeline Stuck

If a pipeline is running too long:
1. Check if waiting for manual approval (10s delay)
2. Review logs for hung processes
3. Cancel and re-run if necessary

### Plan Shows Unexpected Changes

If terraform plan shows changes you didn't make:
1. Review the plan output carefully
2. Check if resources were modified outside Terraform
3. Verify terraform state is current
4. Consider running `terraform refresh` locally

## Best Practices

1. **Always review plans** before applying changes
2. **Use pull requests** for infrastructure changes to see plans first
3. **Monitor pipeline logs** during execution
4. **Test changes locally** before pushing
5. **Keep commits small** for easier troubleshooting
6. **Use descriptive commit messages** for audit trail

## GitHub Secrets Required

Ensure these secrets are configured in repository settings:

```
Settings → Secrets and variables → Actions
```

Required secrets:
- `AWS_ACCESS_KEY_ID` - AWS access key for bedrock-dev-view user
- `AWS_SECRET_ACCESS_KEY` - AWS secret key for bedrock-dev-view user

## Additional Resources

- [Terraform Documentation](https://www.terraform.io/docs)
- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [AWS EKS Documentation](https://docs.aws.amazon.com/eks/)
- [Project README](README.md)

---

**Last Updated**: February 2026
**Repository**: https://github.com/ififrank2013/bedrock-infra
