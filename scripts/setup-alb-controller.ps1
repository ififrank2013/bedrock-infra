# ALB Ingress Controller Setup Script

$CLUSTER_NAME = "project-bedrock-cluster"
$AWS_ACCOUNT_ID = "197104194412"
$REGION = "us-east-1"
$VPC_ID = "vpc-0a8f9d36574fed19d"

Write-Host "Setting up AWS Load Balancer Controller..." -ForegroundColor Green

# Step 1: Get OIDC provider
Write-Host "`n1. Getting OIDC provider..." -ForegroundColor Yellow
$OIDC_ID = (aws eks describe-cluster --name $CLUSTER_NAME --region $REGION --query "cluster.identity.oidc.issuer" --output text).Split('/')[-1]
Write-Host "OIDC Provider ID: $OIDC_ID"

# Step 2: Create IAM policy (if not exists)
Write-Host "`n2. Creating/Verifying IAM Policy..." -ForegroundColor Yellow
try {
    aws iam get-policy --policy-arn "arn:aws:iam::${AWS_ACCOUNT_ID}:policy/AWSLoadBalancerControllerIAMPolicy" 2>$null
    Write-Host "Policy already exists"
} catch {
    Write-Host "Policy not found, will be created by Helm"
}

# Step 3: Install ALB Controller using Helm
Write-Host "`n3. Installing AWS Load Balancer Controller via Helm..." -ForegroundColor Yellow

wsl bash -c @"
helm install aws-load-balancer-controller eks/aws-load-balancer-controller \
  -n kube-system \
  --set clusterName=$CLUSTER_NAME \
  --set serviceAccount.create=true \
  --set serviceAccount.name=aws-load-balancer-controller \
  --set region=$REGION \
  --set vpcId=$VPC_ID \
  --set serviceAccount.annotations.'eks\.amazonaws\.com/role-arn'=arn:aws:iam::${AWS_ACCOUNT_ID}:role/AmazonEKSLoadBalancerControllerRole \
  --wait --timeout 5m
"@

Write-Host "`n✅ ALB Controller installation complete!" -ForegroundColor Green
