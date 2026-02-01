# ⚡ Quick Reference Card - Project Bedrock

## 🚀 Deployment Commands (Copy & Paste)

### 1. Initialize Git & Push to GitHub
```powershell
cd C:\Users\olivc\OneDrive\Documents\altschool-barakat-cohort\third-semester\capstone-project\bedrock-infra
git init
git add .
git commit -m "Initial commit: Complete Project Bedrock infrastructure"
git remote add origin https://github.com/ififrank2013/bedrock-infra.git
git push -u origin main
```

### 2. Setup Backend
```powershell
cd scripts
.\setup-backend.ps1
```

### 3. Deploy Infrastructure
```powershell
cd ..\terraform
terraform init
terraform plan
terraform apply -auto-approve
```

### 4. Configure kubectl
```powershell
aws eks update-kubeconfig --name project-bedrock-cluster --region us-east-1
kubectl get nodes
```

### 5. Deploy Application
```powershell
cd ..\scripts
.\deploy-app.ps1
```

### 6. Get Application URL
```powershell
kubectl get ingress -n retail-app
```

### 7. Test Lambda
```powershell
"Test" | Out-File test.jpg
aws s3 cp test.jpg s3://bedrock-assets-alt-soe-025-0275/
aws logs tail /aws/lambda/bedrock-asset-processor --since 1m
```

### 8. Get Developer Credentials
```powershell
cd ..\terraform
terraform output developer_access_key_id
terraform output developer_secret_access_key
```

### 9. Generate Grading JSON
```powershell
terraform output -json | Out-File ..\grading.json -Encoding UTF8
git add ..\grading.json
git commit -m "Add grading.json"
git push
```

---

## 🔍 Verification Commands

### Check All Pods Running
```powershell
kubectl get pods -n retail-app
```

### Check Services
```powershell
kubectl get svc -n retail-app
```

### Check Ingress/ALB
```powershell
kubectl get ingress -n retail-app
```

### Check EKS Cluster
```powershell
aws eks describe-cluster --name project-bedrock-cluster --region us-east-1 --query 'cluster.status'
```

### Check RDS Instances
```powershell
aws rds describe-db-instances --query 'DBInstances[*].[DBInstanceIdentifier,DBInstanceStatus]'
```

### Check S3 Bucket
```powershell
aws s3 ls s3://bedrock-assets-alt-soe-025-0275
```

### Check Lambda Function
```powershell
aws lambda get-function --function-name bedrock-asset-processor
```

---

## 📊 Key Information

### Resource Names (MUST NOT CHANGE)
- **Cluster**: `project-bedrock-cluster`
- **VPC**: `project-bedrock-vpc`
- **Namespace**: `retail-app`
- **IAM User**: `bedrock-dev-view`
- **S3 Bucket**: `bedrock-assets-alt-soe-025-0275`
- **Lambda**: `bedrock-asset-processor`

### Region
- **AWS Region**: `us-east-1` (MUST BE us-east-1)

### Tags (All Resources)
```
Project: barakat-2025-capstone
ManagedBy: Terraform
Environment: production
StudentID: ALT-SOE-025-0275
```

---

## 🎯 Required Outputs

From `terraform output`:
- cluster_endpoint
- cluster_name
- region
- vpc_id
- assets_bucket_name

---

## 🔑 GitHub Secrets (Add These)

1. Go to: https://github.com/ififrank2013/bedrock-infra/settings/secrets/actions
2. Add:
   - `AWS_ACCESS_KEY_ID` = Your AWS access key
   - `AWS_SECRET_ACCESS_KEY` = Your AWS secret key

---

## 📝 File Locations

| File | Location |
|------|----------|
| Main README | `/README.md` |
| Deployment Steps | `/DEPLOYMENT_STEPS.md` |
| Project Summary | `/PROJECT_SUMMARY.md` |
| Detailed Guide | `/docs/DEPLOYMENT_GUIDE.md` |
| Submission Template | `/docs/SUBMISSION_TEMPLATE.md` |
| Terraform Code | `/terraform/` |
| Kubernetes Manifests | `/k8s/` |
| Lambda Code | `/lambda/` |
| Scripts | `/scripts/` |
| CI/CD Pipeline | `/.github/workflows/` |

---

## ⏱️ Time Estimates

| Task | Duration |
|------|----------|
| Git Setup | 5 min |
| Backend Setup | 5 min |
| Terraform Apply | 15-20 min |
| App Deployment | 5-10 min |
| Testing | 10 min |
| Documentation | 15 min |
| **TOTAL** | **~70 min** |

---

## 🧹 Cleanup (After Grading)

```powershell
# Delete application
helm uninstall retail-app -n retail-app
kubectl delete namespace retail-app

# Wait for LoadBalancers
Start-Sleep -Seconds 60

# Destroy infrastructure
cd terraform
terraform destroy -auto-approve

# Delete backend (optional)
aws s3 rm s3://bedrock-terraform-state-alt-soe-025-0275 --recursive
aws s3 rb s3://bedrock-terraform-state-alt-soe-025-0275
aws dynamodb delete-table --table-name bedrock-terraform-locks
```

---

## 💰 Cost Alert

**~$392/month** or **~$0.50/hour**

Remember to destroy after grading!

---

## 🆘 Quick Troubleshooting

### Pods Not Starting
```powershell
kubectl describe pod <pod-name> -n retail-app
kubectl logs <pod-name> -n retail-app
```

### ALB Not Created
```powershell
kubectl logs -n kube-system deployment/aws-load-balancer-controller
```

### Terraform Errors
```powershell
terraform refresh
terraform plan
```

### Can't Access Cluster
```powershell
aws eks update-kubeconfig --name project-bedrock-cluster --region us-east-1 --force
```

---

## ✅ Pre-Submission Checklist

- [ ] All pods running
- [ ] Application accessible
- [ ] Lambda tested
- [ ] Developer access tested
- [ ] grading.json generated
- [ ] Code on GitHub
- [ ] Repository public
- [ ] Architecture diagram created
- [ ] Submission document ready

---

## 📞 Support

- **Detailed Guide**: `/docs/DEPLOYMENT_GUIDE.md`
- **README**: `/README.md`
- **Deployment Steps**: `/DEPLOYMENT_STEPS.md`

---

**Quick Start**: Just run commands in order from top to bottom! 🚀
