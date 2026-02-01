# Deploy Retail Application to EKS Cluster (PowerShell Version)
# This script deploys the retail store sample app using Helm

$ErrorActionPreference = "Stop"

Write-Host "================================================" -ForegroundColor Cyan
Write-Host "Deploying Retail Store Application" -ForegroundColor Cyan
Write-Host "================================================" -ForegroundColor Cyan
Write-Host ""

# Configuration
$CLUSTER_NAME = "project-bedrock-cluster"
$AWS_REGION = "us-east-1"
$NAMESPACE = "retail-app"
$HELM_RELEASE = "retail-app"

# Update kubeconfig
Write-Host "🔧 Configuring kubectl..." -ForegroundColor Yellow
aws eks update-kubeconfig --name $CLUSTER_NAME --region $AWS_REGION

# Verify cluster access
Write-Host "✅ Verifying cluster access..." -ForegroundColor Yellow
kubectl cluster-info
kubectl get nodes

# Create namespace if it doesn't exist
Write-Host "📦 Ensuring namespace exists..." -ForegroundColor Yellow
kubectl create namespace $NAMESPACE --dry-run=client -o yaml | kubectl apply -f -

# Add Helm repository
Write-Host "📚 Adding Helm repository..." -ForegroundColor Yellow
helm repo add retail-app https://aws.github.io/retail-store-sample-app
helm repo update

# Deploy the application
Write-Host "🚀 Deploying retail application..." -ForegroundColor Yellow
helm upgrade --install $HELM_RELEASE retail-app/retail-app `
    --namespace $NAMESPACE `
    --values ..\k8s\retail-app-values.yaml `
    --wait `
    --timeout 10m

Write-Host ""
Write-Host "✅ Deployment complete!" -ForegroundColor Green
Write-Host ""

# Get deployment status
Write-Host "📊 Deployment Status:" -ForegroundColor Cyan
kubectl get pods -n $NAMESPACE
Write-Host ""
kubectl get services -n $NAMESPACE
Write-Host ""

# Get Ingress URL
Write-Host "🌐 Getting application URL..." -ForegroundColor Yellow
Start-Sleep -Seconds 30
try {
    $ALB_URL = kubectl get ingress -n $NAMESPACE -o jsonpath='{.items[0].status.loadBalancer.ingress[0].hostname}' 2>$null
    
    if ($ALB_URL) {
        Write-Host ""
        Write-Host "🎉 Application is accessible at: http://$ALB_URL" -ForegroundColor Green
        Write-Host ""
    } else {
        throw "URL not available yet"
    }
} catch {
    Write-Host ""
    Write-Host "⏳ ALB is being provisioned. Check back in a few minutes with:" -ForegroundColor Yellow
    Write-Host "   kubectl get ingress -n $NAMESPACE" -ForegroundColor White
    Write-Host ""
}

Write-Host "To monitor the deployment:" -ForegroundColor Cyan
Write-Host "  kubectl get pods -n $NAMESPACE -w" -ForegroundColor White
Write-Host ""
