# Project Bedrock - Submission Document

**Student Information**
- **Name**: [Your Full Name]
- **Student ID**: ALT/SOE/025/0275
- **GitHub Username**: ififrank2013
- **Email**: [Your Email]
- **Date**: February 2026

---

## 1. Git Repository Link

**Repository URL**: https://github.com/ififrank2013/bedrock-infra

**Repository Access**: Public (or invite Innocent Chukwuemeka if private)

**Key Files**:
- `/terraform/` - All Terraform IaC code
- `/k8s/` - Kubernetes manifests and Helm values
- `/lambda/` - Lambda function code
- `/.github/workflows/` - CI/CD pipeline
- `/grading.json` - Terraform outputs for grading
- `/README.md` - Complete documentation

---

## 2. Architecture Diagram

**Diagram URL**: [Link to architecture diagram image or PDF]

**Key Components**:

### Network Layer
- **VPC**: `project-bedrock-vpc` (10.0.0.0/16)
- **Public Subnets**: 2 subnets across us-east-1a and us-east-1b
- **Private Subnets**: 2 subnets across us-east-1a and us-east-1b
- **NAT Gateways**: 2 NAT Gateways for high availability
- **Internet Gateway**: For public subnet internet access

### Compute Layer
- **EKS Cluster**: `project-bedrock-cluster` (Kubernetes v1.31)
- **Node Group**: t3.large instances, 2-5 nodes
- **Namespace**: `retail-app` for application isolation

### Application Layer
- **UI Service**: Web frontend
- **Catalog Service**: Product catalog management
- **Orders Service**: Order processing
- **Cart Service**: Shopping cart functionality
- **Checkout Service**: Payment processing
- **Assets Service**: Static asset serving

### Data Layer (Bonus)
- **RDS MySQL**: Catalog database (Multi-AZ, encrypted, automated backups)
- **RDS PostgreSQL**: Orders database (Multi-AZ, encrypted, automated backups)
- **Redis**: Session cache
- **RabbitMQ**: Message queue

### Serverless Layer
- **S3 Bucket**: `bedrock-assets-alt-soe-025-0275` for product images
- **Lambda Function**: `bedrock-asset-processor` for image processing
- **CloudWatch**: Centralized logging and monitoring

### Networking Layer (Bonus)
- **Application Load Balancer**: Internet-facing ALB
- **Ingress Controller**: AWS Load Balancer Controller
- **TLS**: Optional HTTPS with ACM certificate

---

## 3. Deployment Guide

### Quick Start

**Prerequisites**:
- AWS CLI v2.x
- Terraform v1.5+
- kubectl v1.28+
- Helm v3.13+
- Git

**Step 1: Clone Repository**
```bash
git clone https://github.com/ififrank2013/bedrock-infra.git
cd bedrock-infra
```

**Step 2: Setup Backend**
```bash
cd scripts
./setup-backend.sh  # or setup-backend.ps1 on Windows
```

**Step 3: Deploy Infrastructure**
```bash
cd ../terraform
terraform init
terraform plan
terraform apply
```

**Step 4: Configure kubectl**
```bash
aws eks update-kubeconfig --name project-bedrock-cluster --region us-east-1
```

**Step 5: Deploy Application**
```bash
cd ../scripts
./deploy-app.sh  # or deploy-app.ps1 on Windows
```

**Step 6: Access Application**
```bash
kubectl get ingress -n retail-app
# Access the ALB URL shown in the ADDRESS column
```

### Detailed Documentation

For comprehensive step-by-step instructions, see:
- **README.md**: Overview and quick start
- **docs/DEPLOYMENT_GUIDE.md**: Detailed deployment guide with troubleshooting

---

## 4. Application URL

**Retail Store Application**:
- **URL**: http://[ALB-DNS-NAME]
- **Example**: http://k8s-retailap-xxxxxxxx-yyyyyyyy.us-east-1.elb.amazonaws.com

**How to Get URL**:
```bash
kubectl get ingress retail-app-ingress -n retail-app -o jsonpath='{.status.loadBalancer.ingress[0].hostname}'
```

**Application Features**:
- Product browsing
- Shopping cart
- Order placement
- User authentication
- Asset management

**Health Check**:
```bash
curl http://[ALB-DNS-NAME]/
# Should return 200 OK with HTML content
```

---

## 5. Grading Credentials

### Developer IAM User: `bedrock-dev-view`

**Access Key ID**: `[Retrieved from Terraform output]`

**To retrieve credentials**:
```bash
cd terraform
terraform output developer_access_key_id
terraform output developer_secret_access_key
```

**Secret Access Key**: `[Retrieved from Terraform output - KEEP SECURE]`

**User Permissions**:
- **AWS Console**: ReadOnlyAccess policy (view resources, cannot modify)
- **Kubernetes**: View ClusterRole (read-only access to all namespaces)

**Test Commands**:
```bash
# Configure AWS CLI with these credentials
aws configure --profile bedrock-dev

# Test AWS read access
aws eks describe-cluster --name project-bedrock-cluster --region us-east-1 --profile bedrock-dev

# Configure kubectl
aws eks update-kubeconfig --name project-bedrock-cluster --region us-east-1 --profile bedrock-dev

# Test Kubernetes read access (should work)
kubectl get pods -n retail-app
kubectl get nodes
kubectl describe pod [POD-NAME] -n retail-app

# Test write access (should fail)
kubectl delete pod [POD-NAME] -n retail-app
# Expected: Error - Forbidden
```

---

## 6. Grading Data

### Terraform Outputs

**grading.json Location**: `/grading.json` in repository root

**To generate/update**:
```bash
cd terraform
terraform output -json > ../grading.json
```

**Key Outputs** (from grading.json):
- `cluster_endpoint`: EKS API server endpoint
- `cluster_name`: "project-bedrock-cluster"
- `region`: "us-east-1"
- `vpc_id`: VPC identifier
- `assets_bucket_name`: "bedrock-assets-alt-soe-025-0275"

### Resource Verification Commands

**EKS Cluster**:
```bash
aws eks describe-cluster --name project-bedrock-cluster --region us-east-1 --query 'cluster.{Name:name,Status:status,Version:version,Endpoint:endpoint}'
```

**VPC**:
```bash
aws ec2 describe-vpcs --filters "Name=tag:Name,Values=project-bedrock-vpc" --query 'Vpcs[0].{VpcId:VpcId,CidrBlock:CidrBlock}'
```

**Application Pods**:
```bash
kubectl get pods -n retail-app -o wide
```

**S3 Bucket**:
```bash
aws s3 ls s3://bedrock-assets-alt-soe-025-0275
```

**Lambda Function**:
```bash
aws lambda get-function --function-name bedrock-asset-processor --query 'Configuration.{FunctionName:FunctionName,Runtime:Runtime,Handler:Handler}'
```

---

## 7. Core Requirements Completion

### ✅ 4.1 Infrastructure as Code (IaC)

**Status**: Complete

**Evidence**:
- All infrastructure defined in Terraform
- VPC with public/private subnets across 2 AZs (us-east-1a, us-east-1b)
- EKS cluster v1.31 named `project-bedrock-cluster`
- IAM roles follow least-privilege principle
- Remote state in S3 with DynamoDB locking

**Files**: `/terraform/main.tf`, `/terraform/modules/`

---

### ✅ 4.2 Application Deployment

**Status**: Complete

**Evidence**:
- Retail Store Sample App deployed via Helm
- Running in `retail-app` namespace
- In-cluster dependencies (MySQL, PostgreSQL, Redis, RabbitMQ)
- All pods healthy and running

**Files**: `/k8s/retail-app-values.yaml`

**Verification**:
```bash
kubectl get pods -n retail-app
# All pods should show STATUS: Running
```

---

### ✅ 4.3 Secure Developer Access

**Status**: Complete

**Evidence**:
- IAM user `bedrock-dev-view` created
- AWS Console: ReadOnlyAccess policy attached
- Kubernetes: Mapped to `view` ClusterRole
- Access keys generated and provided

**Files**: `/terraform/modules/iam/`, `/terraform/modules/k8s-rbac/`

**Verification**:
```bash
# Read access works
kubectl get pods -n retail-app --as system:serviceaccount:retail-app:default

# Write access denied
kubectl delete pod [POD] -n retail-app --as system:serviceaccount:retail-app:default
```

---

### ✅ 4.4 Observability (Logging)

**Status**: Complete

**Evidence**:
- EKS Control Plane logging enabled (API, Audit, Authenticator, ControllerManager, Scheduler)
- CloudWatch Observability add-on installed
- Container logs shipping to CloudWatch
- Log groups created with proper retention

**Files**: `/terraform/modules/observability/`

**Verification**:
```bash
# Control plane logs
aws logs describe-log-groups --log-group-name-prefix /aws/eks/project-bedrock-cluster

# Container logs
kubectl logs -f deployment/ui -n retail-app
```

---

### ✅ 4.5 Event-Driven Extension (Serverless)

**Status**: Complete

**Evidence**:
- S3 bucket: `bedrock-assets-alt-soe-025-0275`
- Lambda function: `bedrock-asset-processor`
- S3 event notification configured
- Lambda logs file uploads to CloudWatch

**Files**: `/lambda/asset_processor.py`, `/terraform/modules/serverless/`

**Verification**:
```bash
# Upload test file
echo "Test" > test.jpg
aws s3 cp test.jpg s3://bedrock-assets-alt-soe-025-0275/

# Check logs
aws logs tail /aws/lambda/bedrock-asset-processor --follow
# Should show: "Image received: test.jpg"
```

---

### ✅ 4.6 CI/CD Automation

**Status**: Complete

**Evidence**:
- GitHub Actions workflow configured
- Pull Request: Runs `terraform plan`
- Merge to Main: Runs `terraform apply`
- AWS credentials stored as GitHub secrets
- Automatic application deployment

**Files**: `/.github/workflows/terraform.yml`

**Pipeline Features**:
- Terraform format check
- Terraform validation
- Plan preview on PR
- Auto-apply on merge
- Application deployment
- grading.json generation

---

## 8. Bonus Objectives Completion

### ✅ 5.1 Managed Persistence Layer

**Status**: Complete

**Evidence**:
- RDS MySQL instance for Catalog service
- RDS PostgreSQL instance for Orders service
- Multi-AZ deployment for high availability
- Automated backups with 7-day retention
- Encryption at rest enabled
- Credentials stored in AWS Secrets Manager

**Files**: `/terraform/modules/rds/`, `/k8s/retail-app-values-rds.yaml`

**Cost Optimization**:
- Using db.t3.micro instances
- GP3 storage for better price/performance
- Automated backups during low-traffic hours

**Verification**:
```bash
aws rds describe-db-instances --query 'DBInstances[*].[DBInstanceIdentifier,Engine,DBInstanceStatus]'
```

---

### ✅ 5.2 Advanced Networking & Ingress

**Status**: Complete

**Evidence**:
- AWS Load Balancer Controller installed
- Ingress resource configured
- Application Load Balancer provisioned
- Internet-facing access enabled
- Target type: IP mode for EKS
- Health checks configured

**Files**: `/terraform/modules/alb-controller/`, `/k8s/ingress.yaml`

**Optional Features**:
- TLS termination support (with ACM certificate)
- HTTPS redirect capability
- Custom domain support

**Verification**:
```bash
kubectl get ingress -n retail-app
# Should show ADDRESS with ALB DNS name
```

---

## 9. Compliance with Technical Standards

### ✅ Naming Conventions

| Resource | Required Name | Actual Name | ✅ |
|----------|--------------|-------------|-----|
| AWS Region | us-east-1 | us-east-1 | ✅ |
| EKS Cluster | project-bedrock-cluster | project-bedrock-cluster | ✅ |
| VPC | project-bedrock-vpc | project-bedrock-vpc | ✅ |
| Namespace | retail-app | retail-app | ✅ |
| IAM User | bedrock-dev-view | bedrock-dev-view | ✅ |
| S3 Bucket | bedrock-assets-[student-id] | bedrock-assets-alt-soe-025-0275 | ✅ |
| Lambda | bedrock-asset-processor | bedrock-asset-processor | ✅ |

### ✅ Resource Tagging

All resources tagged with:
```
Project: barakat-2025-capstone
ManagedBy: Terraform
Environment: production
StudentID: ALT-SOE-025-0275
```

**Verification**:
```bash
# Check EKS tags
aws eks describe-cluster --name project-bedrock-cluster --query 'cluster.tags'

# Check VPC tags
aws ec2 describe-vpcs --filters "Name=tag:Name,Values=project-bedrock-vpc" --query 'Vpcs[0].Tags'
```

### ✅ Terraform Outputs

Required outputs present in root module:
- ✅ cluster_endpoint
- ✅ cluster_name
- ✅ region
- ✅ vpc_id
- ✅ assets_bucket_name

**Verification**:
```bash
cd terraform
terraform output
```

---

## 10. Testing and Validation

### Application Testing

**Test 1: Web Interface**
```bash
# Get URL
ALB_URL=$(kubectl get ingress retail-app-ingress -n retail-app -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')

# Test homepage
curl -I http://$ALB_URL
# Expected: HTTP/1.1 200 OK

# Open in browser
open http://$ALB_URL
```

**Test 2: Service Communication**
```bash
# Test internal service communication
kubectl exec -it deployment/ui -n retail-app -- curl catalog:8080/health
# Expected: {"status":"healthy"}
```

### Lambda Testing

**Test 3: S3 Event Trigger**
```bash
# Upload file
aws s3 cp test-image.jpg s3://bedrock-assets-alt-soe-025-0275/products/

# Verify processing
aws logs tail /aws/lambda/bedrock-asset-processor --since 1m
# Expected: "Image received: products/test-image.jpg"
```

### Security Testing

**Test 4: Developer Access**
```bash
# Configure developer credentials
aws configure --profile bedrock-dev
# [Enter access key and secret from grading credentials]

# Test read access (should work)
kubectl get pods -n retail-app

# Test write access (should fail)
kubectl delete pod [POD-NAME] -n retail-app
# Expected: Error from server (Forbidden)
```

### Observability Testing

**Test 5: CloudWatch Logs**
```bash
# View control plane logs
aws logs tail /aws/eks/project-bedrock-cluster/cluster --since 10m

# View application logs
kubectl logs deployment/catalog -n retail-app --tail=50
```

---

## 11. Cost Considerations

### Monthly Cost Estimate

| Service | Configuration | Est. Cost/Month |
|---------|--------------|-----------------|
| EKS Cluster | 1 cluster | $72 |
| EC2 (Nodes) | 3 x t3.large | ~$190 |
| NAT Gateway | 2 gateways | ~$65 |
| ALB | 1 load balancer | ~$23 |
| RDS MySQL | db.t3.micro | ~$15 |
| RDS PostgreSQL | db.t3.micro | ~$15 |
| S3 | Storage + requests | ~$1 |
| CloudWatch | Logs + metrics | ~$10 |
| **Total** | | **~$391/month** |

**Cost Optimization Strategies**:
1. Use Spot Instances for non-production workloads
2. Enable cluster autoscaler to scale down during low traffic
3. Use S3 lifecycle policies for old assets
4. Optimize CloudWatch log retention
5. Consider Reserved Instances for predictable workloads

---

## 12. Security Best Practices Implemented

### Network Security
- ✅ Private subnets for EKS nodes
- ✅ Security groups with least-privilege rules
- ✅ NAT Gateways for controlled egress

### IAM Security
- ✅ Least-privilege IAM roles
- ✅ IAM Roles for Service Accounts (IRSA)
- ✅ No hardcoded credentials

### Data Security
- ✅ S3 bucket encryption (AES-256)
- ✅ RDS encryption at rest
- ✅ Secrets stored in AWS Secrets Manager
- ✅ TLS for data in transit (optional HTTPS)

### Kubernetes Security
- ✅ RBAC enabled
- ✅ Namespace isolation
- ✅ Read-only developer access
- ✅ Pod security standards

---

## 13. Known Limitations and Future Improvements

### Current Limitations
1. No multi-region deployment (single region: us-east-1)
2. Basic monitoring (CloudWatch only, no Prometheus/Grafana)
3. No disaster recovery automation
4. Manual RDS password rotation

### Future Improvements
1. **High Availability**: Multi-region EKS cluster with Global Accelerator
2. **Advanced Monitoring**: Prometheus, Grafana, and Jaeger for distributed tracing
3. **GitOps**: ArgoCD for application deployment
4. **Security**: Implement OPA/Gatekeeper for policy enforcement
5. **Scaling**: Cluster autoscaler and HPA for applications
6. **Backup**: Velero for Kubernetes backup and restore
7. **Cost**: FinOps dashboard for cost optimization
8. **Secrets**: External Secrets Operator for secret management

---

## 14. Documentation Links

### Repository Documentation
- **Main README**: https://github.com/ififrank2013/bedrock-infra/blob/main/README.md
- **Deployment Guide**: https://github.com/ififrank2013/bedrock-infra/blob/main/docs/DEPLOYMENT_GUIDE.md
- **Terraform Modules**: https://github.com/ififrank2013/bedrock-infra/tree/main/terraform/modules

### AWS Resources
- **EKS Best Practices**: https://aws.github.io/aws-eks-best-practices/
- **Retail Store Sample App**: https://github.com/aws-containers/retail-store-sample-app
- **AWS Load Balancer Controller**: https://kubernetes-sigs.github.io/aws-load-balancer-controller/

---

## 15. Acknowledgments

Special thanks to:
- **AltSchool Africa** - For providing this comprehensive assessment
- **Innocent Chukwuemeka** - For course instruction and guidance
- **AWS** - For excellent documentation and sample applications
- **Terraform** - For infrastructure as code tooling
- **Kubernetes Community** - For container orchestration platform

---

## 16. Contact Information

**Student**: [Your Name]
**Email**: [Your Email]
**GitHub**: [@ififrank2013](https://github.com/ififrank2013)
**LinkedIn**: [Your LinkedIn]

**For Questions or Issues**:
- Open an issue on GitHub: https://github.com/ififrank2013/bedrock-infra/issues
- Email: [Your Email]

---

## 17. Declaration

I hereby declare that:
1. This work is my own original work
2. All resources have been properly cited
3. The infrastructure adheres to AWS best practices
4. All naming conventions and standards have been followed
5. The deployment has been tested and validated

**Signature**: ___________________
**Date**: February 2026

---

**END OF SUBMISSION DOCUMENT**

---

## Quick Access Links

- 🔗 **GitHub Repository**: https://github.com/ififrank2013/bedrock-infra
- 🌐 **Application URL**: [Your ALB URL]
- 📊 **Architecture Diagram**: [Your diagram link]
- 📝 **Grading JSON**: https://github.com/ififrank2013/bedrock-infra/blob/main/grading.json
- 📚 **Documentation**: https://github.com/ififrank2013/bedrock-infra/blob/main/README.md

**Project Status**: ✅ Complete and Ready for Grading
