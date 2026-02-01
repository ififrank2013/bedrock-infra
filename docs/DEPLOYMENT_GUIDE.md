# Project Bedrock - Detailed Deployment Guide

This comprehensive guide will walk you through deploying the complete Project Bedrock infrastructure from start to finish.

## Table of Contents

1. [Prerequisites](#prerequisites)
2. [Initial Setup](#initial-setup)
3. [Backend Configuration](#backend-configuration)
4. [Infrastructure Deployment](#infrastructure-deployment)
5. [Application Deployment](#application-deployment)
6. [Verification and Testing](#verification-and-testing)
7. [Optional: RDS Integration](#optional-rds-integration)
8. [Optional: HTTPS Configuration](#optional-https-configuration)
9. [Troubleshooting](#troubleshooting)

## Prerequisites

### 1. Install Required Tools

#### AWS CLI

**macOS:**
```bash
curl "https://awscli.amazonaws.com/AWSCLIV2.pkg" -o "AWSCLIV2.pkg"
sudo installer -pkg AWSCLIV2.pkg -target /
```

**Linux:**
```bash
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install
```

**Windows:**
Download and run: https://awscli.amazonaws.com/AWSCLIV2.msi

**Verify:**
```bash
aws --version  # Should show v2.x
```

#### Terraform

**macOS:**
```bash
brew tap hashicorp/tap
brew install hashicorp/terraform
```

**Linux:**
```bash
wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt update && sudo apt install terraform
```

**Windows:**
Download from: https://www.terraform.io/downloads

**Verify:**
```bash
terraform version  # Should show v1.5+
```

#### kubectl

**macOS:**
```bash
brew install kubectl
```

**Linux:**
```bash
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
```

**Windows:**
```powershell
curl.exe -LO "https://dl.k8s.io/release/v1.28.0/bin/windows/amd64/kubectl.exe"
```

**Verify:**
```bash
kubectl version --client  # Should show v1.28+
```

#### Helm

**macOS:**
```bash
brew install helm
```

**Linux:**
```bash
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
```

**Windows:**
```powershell
choco install kubernetes-helm
```

**Verify:**
```bash
helm version  # Should show v3.13+
```

### 2. Configure AWS Credentials

```bash
aws configure
```

Provide:
- **AWS Access Key ID**: Your access key
- **AWS Secret Access Key**: Your secret key
- **Default region name**: `us-east-1`
- **Default output format**: `json`

**Verify:**
```bash
aws sts get-caller-identity
```

### 3. Verify IAM Permissions

Ensure your IAM user/role has permissions for:
- EC2 (VPC, Subnets, NAT Gateways)
- EKS (Clusters, Node Groups)
- IAM (Roles, Policies, Users)
- S3 (Buckets, Objects)
- Lambda (Functions)
- RDS (Instances, Subnet Groups)
- CloudWatch (Log Groups)
- Elastic Load Balancing (ALB, Target Groups)

## Initial Setup

### 1. Clone the Repository

```bash
git clone https://github.com/ififrank2013/bedrock-infra.git
cd bedrock-infra
```

### 2. Review Configuration

Edit `terraform/variables.tf` if you want to customize:

```hcl
variable "aws_region" {
  default     = "us-east-1"  # Keep as us-east-1 for grading
}

variable "cluster_version" {
  default     = "1.31"        # EKS version
}

variable "node_instance_types" {
  default     = ["t3.large"]  # Adjust based on workload
}

variable "enable_rds" {
  default     = true          # Set to false to disable RDS
}

variable "enable_alb_ingress" {
  default     = true          # Set to false to disable ALB
}
```

**⚠️ Important**: Do NOT change resource names:
- Cluster name: `project-bedrock-cluster`
- VPC name: `project-bedrock-vpc`
- Namespace: `retail-app`
- Developer user: `bedrock-dev-view`

## Backend Configuration

### 1. Run Backend Setup Script

**On Linux/macOS:**
```bash
cd scripts
chmod +x setup-backend.sh
./setup-backend.sh
cd ..
```

**On Windows (PowerShell):**
```powershell
cd scripts
.\setup-backend.ps1
cd ..
```

This script creates:
- S3 bucket: `bedrock-terraform-state-alt-soe-025-0275`
- DynamoDB table: `bedrock-terraform-locks`

### 2. Verify Backend Resources

```bash
# Check S3 bucket
aws s3 ls | grep bedrock-terraform-state

# Check DynamoDB table
aws dynamodb describe-table --table-name bedrock-terraform-locks
```

## Infrastructure Deployment

### 1. Initialize Terraform

```bash
cd terraform
terraform init
```

Expected output:
```
Initializing modules...
Initializing the backend...
Successfully configured the backend "s3"!
Terraform has been successfully initialized!
```

### 2. Review the Plan

```bash
terraform plan
```

Review the resources to be created:
- VPC and subnets
- EKS cluster and node group
- IAM roles and users
- S3 bucket and Lambda function
- CloudWatch log groups
- RDS instances (if enabled)
- ALB controller (if enabled)

### 3. Apply Infrastructure

```bash
terraform apply
```

Type `yes` when prompted.

**⏱️ Expected duration**: 15-20 minutes

**Progress indicators:**
- ✅ VPC created (~2 min)
- ✅ EKS cluster created (~10 min)
- ✅ Node group created (~5 min)
- ✅ Add-ons installed (~2 min)

### 4. Verify Deployment

```bash
# Check EKS cluster
aws eks describe-cluster --name project-bedrock-cluster --region us-east-1

# Get outputs
terraform output
```

### 5. Configure kubectl

```bash
aws eks update-kubeconfig --name project-bedrock-cluster --region us-east-1

# Verify connection
kubectl get nodes
kubectl get namespaces
```

Expected output:
```
NAME                                       STATUS   ROLES    AGE   VERSION
ip-10-0-11-xxx.ec2.internal               Ready    <none>   5m    v1.31.0
ip-10-0-12-xxx.ec2.internal               Ready    <none>   5m    v1.31.0
```

## Application Deployment

### Option A: Automated Deployment (Recommended)

**On Linux/macOS:**
```bash
cd ../scripts
chmod +x deploy-app.sh
./deploy-app.sh
```

**On Windows (PowerShell):**
```powershell
cd ..\scripts
.\deploy-app.ps1
```

### Option B: Manual Deployment

#### 1. Add Helm Repository

```bash
helm repo add retail-app https://aws.github.io/retail-store-sample-app
helm repo update
```

#### 2. Create Namespace

```bash
kubectl create namespace retail-app
```

#### 3. Deploy Application

**Without RDS (in-cluster databases):**
```bash
helm install retail-app retail-app/retail-app \
  --namespace retail-app \
  --values ../k8s/retail-app-values.yaml \
  --wait \
  --timeout 10m
```

**With RDS:**
```bash
# First, get RDS endpoints from Terraform
cd ../terraform
MYSQL_ENDPOINT=$(terraform output -raw rds_mysql_endpoint)
POSTGRES_ENDPOINT=$(terraform output -raw rds_postgres_endpoint)

# Get RDS passwords from Secrets Manager
MYSQL_PASSWORD=$(aws secretsmanager get-secret-value --secret-id bedrock/rds/mysql-credentials --query SecretString --output text | jq -r .password)
POSTGRES_PASSWORD=$(aws secretsmanager get-secret-value --secret-id bedrock/rds/postgres-credentials --query SecretString --output text | jq -r .password)

# Create Kubernetes secrets
kubectl create secret generic catalog-db-secret \
  --namespace retail-app \
  --from-literal=username=catalogadmin \
  --from-literal=password=$MYSQL_PASSWORD \
  --from-literal=host=$MYSQL_ENDPOINT \
  --from-literal=port=3306 \
  --from-literal=database=catalog

kubectl create secret generic orders-db-secret \
  --namespace retail-app \
  --from-literal=username=ordersadmin \
  --from-literal=password=$POSTGRES_PASSWORD \
  --from-literal=host=$POSTGRES_ENDPOINT \
  --from-literal=port=5432 \
  --from-literal=database=orders

# Deploy with RDS values
helm install retail-app retail-app/retail-app \
  --namespace retail-app \
  --values ../k8s/retail-app-values-rds.yaml \
  --wait \
  --timeout 10m
```

#### 4. Deploy Ingress

```bash
kubectl apply -f ../k8s/ingress.yaml
```

## Verification and Testing

### 1. Check Pod Status

```bash
kubectl get pods -n retail-app
```

All pods should be in `Running` state:
```
NAME                        READY   STATUS    RESTARTS   AGE
ui-xxx                      1/1     Running   0          2m
catalog-xxx                 1/1     Running   0          2m
orders-xxx                  1/1     Running   0          2m
cart-xxx                    1/1     Running   0          2m
checkout-xxx                1/1     Running   0          2m
assets-xxx                  1/1     Running   0          2m
```

### 2. Check Services

```bash
kubectl get svc -n retail-app
```

### 3. Check Ingress

```bash
kubectl get ingress -n retail-app
```

Wait for the ALB to be provisioned (2-5 minutes):
```
NAME                  CLASS   HOSTS   ADDRESS                                    PORTS   AGE
retail-app-ingress   alb     *       xxx.us-east-1.elb.amazonaws.com           80      3m
```

### 4. Access the Application

```bash
# Get ALB URL
ALB_URL=$(kubectl get ingress retail-app-ingress -n retail-app -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')
echo "Application URL: http://$ALB_URL"

# Test with curl
curl http://$ALB_URL

# Or open in browser
open http://$ALB_URL  # macOS
xdg-open http://$ALB_URL  # Linux
start http://$ALB_URL  # Windows
```

### 5. Test Lambda Function

```bash
# Upload test file
echo "Test product image" > test-image.jpg
aws s3 cp test-image.jpg s3://bedrock-assets-alt-soe-025-0275/products/

# Check Lambda logs
aws logs tail /aws/lambda/bedrock-asset-processor --follow
```

Expected output in logs:
```
Image received: products/test-image.jpg
```

### 6. Test CloudWatch Logging

```bash
# View EKS control plane logs
aws logs tail /aws/eks/project-bedrock-cluster/cluster --follow

# View container logs
kubectl logs -f deployment/ui -n retail-app
```

### 7. Test Developer Access

```bash
# Get developer credentials
cd terraform
terraform output developer_access_key_id
terraform output developer_secret_access_key

# Configure a separate AWS profile
aws configure --profile bedrock-dev
# Enter the developer credentials

# Test read access (should work)
aws eks describe-cluster --name project-bedrock-cluster --region us-east-1 --profile bedrock-dev

# Update kubeconfig with developer profile
aws eks update-kubeconfig --name project-bedrock-cluster --region us-east-1 --profile bedrock-dev

# Test Kubernetes read access (should work)
kubectl get pods -n retail-app
kubectl get nodes
kubectl describe pod <pod-name> -n retail-app

# Test write access (should fail)
kubectl delete pod <pod-name> -n retail-app
# Error: User cannot delete resource "pods" in API group ""
```

## Optional: RDS Integration

If you deployed with `enable_rds = true`, the application is already using RDS. Here's how to verify:

### 1. Check RDS Instances

```bash
aws rds describe-db-instances --query 'DBInstances[*].[DBInstanceIdentifier,Endpoint.Address,DBInstanceStatus]'
```

### 2. Connect to RDS (for testing)

```bash
# Get credentials from Secrets Manager
MYSQL_ENDPOINT=$(cd terraform && terraform output -raw rds_mysql_endpoint)
MYSQL_PASSWORD=$(aws secretsmanager get-secret-value --secret-id bedrock/rds/mysql-credentials --query SecretString --output text | jq -r .password)

# Connect (requires mysql client)
mysql -h $MYSQL_ENDPOINT -u catalogadmin -p$MYSQL_PASSWORD catalog
```

### 3. Verify Application is Using RDS

```bash
# Check catalog pod logs
kubectl logs -l app=catalog -n retail-app | grep -i "database"

# The logs should show connection to RDS endpoint
```

## Optional: HTTPS Configuration

### 1. Request ACM Certificate

```bash
# Request certificate for your domain
aws acm request-certificate \
  --domain-name yourdomain.com \
  --subject-alternative-names "*.yourdomain.com" \
  --validation-method DNS \
  --region us-east-1

# Get certificate ARN
aws acm list-certificates --region us-east-1
```

### 2. Validate Certificate

Follow the DNS validation instructions in the AWS Console or CLI.

### 3. Update Ingress

Edit `k8s/ingress.yaml`:

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: retail-app-ingress
  namespace: retail-app
  annotations:
    alb.ingress.kubernetes.io/scheme: internet-facing
    alb.ingress.kubernetes.io/target-type: ip
    alb.ingress.kubernetes.io/certificate-arn: arn:aws:acm:us-east-1:ACCOUNT_ID:certificate/CERT_ID
    alb.ingress.kubernetes.io/listen-ports: '[{"HTTP": 80}, {"HTTPS": 443}]'
    alb.ingress.kubernetes.io/ssl-redirect: '443'
spec:
  ingressClassName: alb
  rules:
    - host: yourdomain.com
      http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: ui
                port:
                  number: 8080
```

Apply the changes:
```bash
kubectl apply -f k8s/ingress.yaml
```

### 4. Configure DNS

Point your domain to the ALB:

```bash
ALB_URL=$(kubectl get ingress retail-app-ingress -n retail-app -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')
echo "Create a CNAME record: yourdomain.com -> $ALB_URL"
```

## Troubleshooting

### Issue: Terraform init fails

**Error**: `Error: Failed to get existing workspaces`

**Solution**:
```bash
# Verify AWS credentials
aws sts get-caller-identity

# Check backend bucket exists
aws s3 ls s3://bedrock-terraform-state-alt-soe-025-0275

# Re-run backend setup
cd scripts
./setup-backend.sh
```

### Issue: EKS cluster creation times out

**Error**: `timeout while waiting for resource creation`

**Solution**:
```bash
# Check CloudFormation stacks
aws cloudformation describe-stacks --region us-east-1

# If stack is in ROLLBACK state, delete and retry
terraform destroy -target=module.eks
terraform apply
```

### Issue: Pods stuck in Pending state

**Error**: Pods not starting

**Solution**:
```bash
# Check node status
kubectl get nodes

# Describe pod for details
kubectl describe pod <pod-name> -n retail-app

# Common causes:
# 1. Insufficient resources - scale node group
# 2. Image pull errors - check image name
# 3. PVC not bound - check storage class
```

### Issue: ALB not created

**Error**: Ingress has no ADDRESS

**Solution**:
```bash
# Check ALB controller logs
kubectl logs -n kube-system deployment/aws-load-balancer-controller

# Verify service account
kubectl get sa aws-load-balancer-controller -n kube-system -o yaml

# Check IAM role annotations
kubectl describe sa aws-load-balancer-controller -n kube-system

# Restart ALB controller
kubectl rollout restart deployment aws-load-balancer-controller -n kube-system
```

### Issue: Cannot access application

**Error**: Connection refused or timeout

**Solution**:
```bash
# Verify ALB is active
aws elbv2 describe-load-balancers --region us-east-1

# Check target health
ALB_ARN=$(aws elbv2 describe-load-balancers --query "LoadBalancers[?contains(DNSName, 'k8s-retailap')].LoadBalancerArn" --output text)
aws elbv2 describe-target-health --target-group-arn <target-group-arn>

# Check security groups
kubectl get ingress retail-app-ingress -n retail-app -o yaml | grep alb.ingress
```

### Issue: Lambda not triggering

**Error**: No logs when uploading to S3

**Solution**:
```bash
# Check Lambda function exists
aws lambda get-function --function-name bedrock-asset-processor

# Check S3 event notification
aws s3api get-bucket-notification-configuration --bucket bedrock-assets-alt-soe-025-0275

# Test Lambda manually
aws lambda invoke --function-name bedrock-asset-processor --payload '{"Records":[{"s3":{"bucket":{"name":"test"},"object":{"key":"test.jpg"}}}]}' response.json
cat response.json
```

### Issue: Developer cannot access cluster

**Error**: `error: You must be logged in to the server (Unauthorized)`

**Solution**:
```bash
# Verify IAM user exists
aws iam get-user --user-name bedrock-dev-view

# Check aws-auth ConfigMap
kubectl get configmap aws-auth -n kube-system -o yaml

# Verify RBAC binding
kubectl get clusterrolebinding bedrock-developer-view-binding -o yaml

# Re-apply aws-auth
cd terraform
terraform apply -target=module.k8s_rbac
```

## Generate Grading JSON

```bash
cd terraform
terraform output -json > ../grading.json
cat ../grading.json
```

Verify the JSON contains:
- `cluster_endpoint`
- `cluster_name`
- `region`
- `vpc_id`
- `assets_bucket_name`

## Next Steps

1. ✅ Verify all pods are running
2. ✅ Test application access
3. ✅ Test Lambda function
4. ✅ Test developer access
5. ✅ Generate grading.json
6. ✅ Commit code to GitHub
7. ✅ Prepare submission document

## Cleanup

When you're done and want to destroy all resources:

```bash
cd scripts
./cleanup.sh
```

Or manually:
```bash
# Delete application
helm uninstall retail-app -n retail-app
kubectl delete namespace retail-app

# Destroy infrastructure
cd terraform
terraform destroy

# Delete backend (optional)
aws s3 rb s3://bedrock-terraform-state-alt-soe-025-0275 --force
aws dynamodb delete-table --table-name bedrock-terraform-locks
```

---

## Summary Checklist

- [ ] All prerequisites installed
- [ ] AWS credentials configured
- [ ] Backend setup complete
- [ ] Terraform applied successfully
- [ ] kubectl configured
- [ ] Application deployed
- [ ] All pods running
- [ ] Application accessible via ALB
- [ ] Lambda function tested
- [ ] CloudWatch logs verified
- [ ] Developer access tested
- [ ] grading.json generated
- [ ] Code committed to GitHub
- [ ] Documentation complete

**Congratulations! Your Project Bedrock deployment is complete! 🎉**
