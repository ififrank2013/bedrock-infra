# DEPLOYMENT STEPS - Execute These Commands in Order

This guide walks you through deploying Project Bedrock from start to finish.

## IMPORTANT PREREQUISITES

Before starting, ensure you have:
1. AWS Account with appropriate IAM permissions
2. AWS CLI v2.x installed and configured
3. Terraform v1.5+ installed
4. kubectl v1.28+ installed
5. Helm v3.13+ installed
6. Git installed

---

## STEP 1: Initialize Git Repository

```powershell
# Navigate to bedrock-infra directory
cd C:\Users\olivc\OneDrive\Documents\altschool-barakat-cohort\third-semester\capstone-project\bedrock-infra

# Initialize git repository
git init

# Add all files
git add .

# Make initial commit
git commit -m "Initial commit: Complete Project Bedrock infrastructure"
```

---

## STEP 2: Create GitHub Repository

1. Go to https://github.com/new
2. Repository name: `bedrock-infra`
3. Description: "Project Bedrock - InnovateMart EKS Infrastructure (AltSchool Capstone)"
4. Make it **Public**
5. Do NOT initialize with README (it is already included)
6. Click "Create repository"

Then push your code:

```powershell
# Add remote
git remote add origin https://github.com/ififrank2013/bedrock-infra.git

# Push to GitHub
git branch -M main
git push -u origin main
```

---

## STEP 3: Setup AWS Backend

This creates the S3 bucket and DynamoDB table for Terraform state.

```powershell
# Run the backend setup script
cd scripts
.\setup-backend.ps1

# Verify backend resources were created
aws s3 ls | Select-String "bedrock-terraform-state"
aws dynamodb list-tables | Select-String "bedrock-terraform-locks"
```

**Expected Output:**
```
Backend setup complete!
```

---

## STEP 4: Deploy Infrastructure with Terraform

```powershell
# Navigate to terraform directory
cd ..\terraform

# Initialize Terraform (downloads providers and modules)
terraform init

# Review what will be created (optional but recommended)
terraform plan

# Apply the infrastructure
terraform apply
```

When prompted, type `yes` and press Enter.

**This will take 15-20 minutes.**

**Expected Output:**
```
Apply complete! Resources: 50+ added, 0 changed, 0 destroyed.

Outputs:
cluster_endpoint = "https://xxxxx.gr7.us-east-1.eks.amazonaws.com"
cluster_name = "project-bedrock-cluster"
region = "us-east-1"
vpc_id = "vpc-xxxxx"
assets_bucket_name = "bedrock-assets-alt-soe-025-0275"
...
```

---

## STEP 5: Configure kubectl

```powershell
# Update kubeconfig to access the EKS cluster
aws eks update-kubeconfig --name project-bedrock-cluster --region us-east-1

# Verify cluster access
kubectl cluster-info

# Check nodes are ready
kubectl get nodes
```

**Expected Output:**
```
NAME                                       STATUS   ROLES    AGE     VERSION
ip-10-0-11-xxx.ec2.internal               Ready    <none>   5m      v1.31.0
ip-10-0-12-xxx.ec2.internal               Ready    <none>   5m      v1.31.0
ip-10-0-11-yyy.ec2.internal               Ready    <none>   5m      v1.31.0
```

---

## STEP 6: Deploy Retail Application

```powershell
# Navigate back to scripts directory
cd ..\scripts

# Run the deployment script
.\deploy-app.ps1
```

**This will take 5-10 minutes.**

**Expected Output:**
```
Deployment complete!
Application URL: http://k8s-retailap-xxxxx.us-east-1.elb.amazonaws.com
```

---

## STEP 7: Verify Deployment

### Check All Pods are Running

```powershell
kubectl get pods -n retail-app
```

**Expected:** All pods should show `STATUS: Running` and `READY: 1/1`

### Get Application URL

```powershell
kubectl get ingress -n retail-app
```

Look for the `ADDRESS` column - that's your ALB URL.

### Test Application

```powershell
# Get the URL
$ALB_URL = kubectl get ingress retail-app-ingress -n retail-app -o jsonpath='{.status.loadBalancer.ingress[0].hostname}'

# Test with curl
curl http://$ALB_URL

# Or open in browser
Start-Process "http://$ALB_URL"
```

---

## STEP 8: Test Lambda Function

```powershell
# Create a test image
"Test product image" | Out-File -FilePath test-image.jpg -Encoding ASCII

# Upload to S3
aws s3 cp test-image.jpg s3://bedrock-assets-alt-soe-025-0275/products/

# Check Lambda logs (wait 10 seconds first)
Start-Sleep -Seconds 10
aws logs tail /aws/lambda/bedrock-asset-processor --since 1m
```

**Expected Output in logs:**
```
Image received: products/test-image.jpg
```

---

## STEP 9: Test Developer Access

```powershell
# Get developer credentials
cd ..\terraform
$ACCESS_KEY = terraform output -raw developer_access_key_id
$SECRET_KEY = terraform output -raw developer_secret_access_key

# Display credentials (save these for submission)
Write-Host "Developer Access Key ID: $ACCESS_KEY"
Write-Host "Developer Secret Access Key: $SECRET_KEY"

# Configure a separate AWS profile for the developer
aws configure --profile bedrock-dev
# When prompted:
#   AWS Access Key ID: [paste $ACCESS_KEY]
#   AWS Secret Access Key: [paste $SECRET_KEY]
#   Default region: us-east-1
#   Default output format: json

# Test AWS read access (should work)
aws eks describe-cluster --name project-bedrock-cluster --region us-east-1 --profile bedrock-dev

# Update kubeconfig with developer profile
aws eks update-kubeconfig --name project-bedrock-cluster --region us-east-1 --profile bedrock-dev

# Test Kubernetes read access (should work)
kubectl get pods -n retail-app
kubectl get nodes

# Test write access (should fail with Forbidden error)
$POD = kubectl get pods -n retail-app -o name | Select-Object -First 1
kubectl delete $POD
```

**Expected:** The delete command should fail with "Forbidden" error.

---

## STEP 10: Generate Grading JSON

```powershell
# Generate the grading.json file
cd ..\terraform
terraform output -json | Out-File -FilePath ..\grading.json -Encoding UTF8

# View the file
Get-Content ..\grading.json

# Add to git
cd ..
git add grading.json
git commit -m "Add grading.json with terraform outputs"
git push
```

---

## STEP 11: Setup GitHub Actions Secrets

1. Go to your repository on GitHub: https://github.com/ififrank2013/bedrock-infra
2. Click **Settings** → **Secrets and variables** → **Actions**
3. Click **New repository secret**
4. Add two secrets:

**Secret 1:**
- Name: `AWS_ACCESS_KEY_ID`
- Value: Your AWS access key ID

**Secret 2:**
- Name: `AWS_SECRET_ACCESS_KEY`
- Value: Your AWS secret access key

---

## STEP 12: Test CI/CD Pipeline

```powershell
# Create a test branch
git checkout -b test-cicd

# Make a small change
"# Test change" | Add-Content README.md

# Commit and push
git add README.md
git commit -m "Test CI/CD pipeline"
git push origin test-cicd
```

Then:
1. Go to GitHub and create a Pull Request
2. Watch the GitHub Actions workflow run `terraform plan`
3. Review the plan in the PR comments
4. Merge the PR to trigger `terraform apply`

---

## STEP 13: Create Architecture Diagram

Use one of these tools to create your diagram:
- **Draw.io**: https://app.diagrams.net/
- **Lucidchart**: https://www.lucidchart.com/
- **Excalidraw**: https://excalidraw.com/

Reference the ASCII diagram in README.md for structure.

Save the diagram as `architecture.png` and upload to your repository:

```powershell
# After creating the diagram
cd docs
# Place your architecture.png file here

# Add to git
git add architecture.png
git commit -m "Add architecture diagram"
git push
```

---

## STEP 14: Prepare Submission Document

1. Open `/docs/SUBMISSION_TEMPLATE.md`
2. Fill in all the required information:
   - Your full name
   - Your email
   - Actual ALB URL from Step 7
   - Developer credentials from Step 9
   - Link to architecture diagram

3. Export as PDF or share as Google Doc

### Create Google Doc:
1. Copy contents of SUBMISSION_TEMPLATE.md
2. Go to Google Docs: https://docs.google.com/document/
3. Paste and format the content
4. Get shareable link with "Viewer" access
5. Share with Innocent Chukwuemeka

---

## STEP 15: Final Verification Checklist

Run these commands to verify everything:

```powershell
# 1. EKS Cluster
aws eks describe-cluster --name project-bedrock-cluster --region us-east-1 --query 'cluster.status'
# Expected: "ACTIVE"

# 2. All Pods Running
kubectl get pods -n retail-app
# Expected: All pods STATUS: Running

# 3. Application Accessible
$ALB_URL = kubectl get ingress retail-app-ingress -n retail-app -o jsonpath='{.status.loadBalancer.ingress[0].hostname}'
curl -I "http://$ALB_URL"
# Expected: HTTP/1.1 200 OK

# 4. Lambda Function
aws lambda get-function --function-name bedrock-asset-processor --query 'Configuration.FunctionName'
# Expected: "bedrock-asset-processor"

# 5. S3 Bucket
aws s3 ls s3://bedrock-assets-alt-soe-025-0275
# Expected: List of objects (including your test file)

# 6. CloudWatch Logs
aws logs describe-log-groups --log-group-name-prefix /aws/eks/project-bedrock-cluster
# Expected: List of log groups

# 7. RDS Instances
aws rds describe-db-instances --query 'DBInstances[*].[DBInstanceIdentifier,DBInstanceStatus]'
# Expected: Two instances (mysql and postgres) with status "available"

# 8. VPC
aws ec2 describe-vpcs --filters "Name=tag:Name,Values=project-bedrock-vpc" --query 'Vpcs[0].VpcId'
# Expected: vpc-xxxxx

# 9. Terraform State
aws s3 ls s3://bedrock-terraform-state-alt-soe-025-0275/bedrock/
# Expected: terraform.tfstate file

# 10. GitHub Repository
# Visit: https://github.com/ififrank2013/bedrock-infra
# Verify all files are pushed
```

---

## SUBMISSION CHECKLIST

Before submitting, ensure:

- [ ] GitHub repository is public or access granted to instructor
- [ ] All code is pushed to main branch
- [ ] grading.json is in repository root
- [ ] README.md is complete and accurate
- [ ] Architecture diagram is created and added
- [ ] Application is accessible via ALB URL
- [ ] All pods are running in retail-app namespace
- [ ] Lambda function is working (test with S3 upload)
- [ ] Developer access credentials are documented
- [ ] CloudWatch logs are enabled and accessible
- [ ] RDS instances are running (if enabled)
- [ ] ALB is provisioned and routing traffic
- [ ] CI/CD pipeline is configured in GitHub Actions
- [ ] Submission document is prepared (Google Doc or PDF)
- [ ] All naming conventions are correct
- [ ] All resources are tagged properly

---

## 🎉 CONGRATULATIONS!

You have successfully:
- Deployed a production-grade EKS cluster
- Configured VPC with public/private subnets
- Implemented IAM and RBAC security
- Set up CloudWatch observability
- Created serverless event processing
- Deployed a microservices application
- Implemented CI/CD pipeline
- Added RDS managed databases (bonus)
- Configured ALB with Ingress (bonus)

Your Project Bedrock infrastructure is complete and ready for grading.

---

## 🆘 TROUBLESHOOTING

If something goes wrong, check:

1. **AWS Credentials**: `aws sts get-caller-identity`
2. **Terraform State**: `cd terraform && terraform show`
3. **Cluster Status**: `kubectl cluster-info`
4. **Pod Logs**: `kubectl logs <pod-name> -n retail-app`
5. **Events**: `kubectl get events -n retail-app --sort-by='.lastTimestamp'`

For detailed troubleshooting, see `/docs/DEPLOYMENT_GUIDE.md`.

---

## 🧹 CLEANUP (ONLY AFTER GRADING)

**WARNING: This will delete everything!**

```powershell
# Delete application
helm uninstall retail-app -n retail-app
kubectl delete namespace retail-app

# Wait for LoadBalancers to be deleted
Start-Sleep -Seconds 60

# Destroy infrastructure
cd terraform
terraform destroy

# Type 'yes' when prompted

# Delete backend (optional)
aws s3 rm s3://bedrock-terraform-state-alt-soe-025-0275 --recursive
aws s3 rb s3://bedrock-terraform-state-alt-soe-025-0275
aws dynamodb delete-table --table-name bedrock-terraform-locks
```

---

**Good luck with your submission!**
