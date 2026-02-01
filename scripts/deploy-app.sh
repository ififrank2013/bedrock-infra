#!/bin/bash

# Deploy Retail Application to EKS Cluster
# This script deploys the retail store sample app using Helm

set -e

echo "================================================"
echo "Deploying Retail Store Application"
echo "================================================"
echo ""

# Configuration
CLUSTER_NAME="project-bedrock-cluster"
AWS_REGION="us-east-1"
NAMESPACE="retail-app"
HELM_RELEASE="retail-app"

# Update kubeconfig
echo "🔧 Configuring kubectl..."
aws eks update-kubeconfig --name $CLUSTER_NAME --region $AWS_REGION

# Verify cluster access
echo "✅ Verifying cluster access..."
kubectl cluster-info
kubectl get nodes

# Create namespace if it doesn't exist
echo "📦 Ensuring namespace exists..."
kubectl create namespace $NAMESPACE --dry-run=client -o yaml | kubectl apply -f -

# Add Helm repository
echo "📚 Adding Helm repository..."
helm repo add retail-app https://aws.github.io/retail-store-sample-app
helm repo update

# Deploy the application
echo "🚀 Deploying retail application..."
helm upgrade --install $HELM_RELEASE retail-app/retail-app \
    --namespace $NAMESPACE \
    --values ../k8s/retail-app-values.yaml \
    --wait \
    --timeout 10m

echo ""
echo "✅ Deployment complete!"
echo ""

# Get deployment status
echo "📊 Deployment Status:"
kubectl get pods -n $NAMESPACE
echo ""
kubectl get services -n $NAMESPACE
echo ""

# Get Ingress URL
echo "🌐 Getting application URL..."
sleep 30
ALB_URL=$(kubectl get ingress -n $NAMESPACE -o jsonpath='{.items[0].status.loadBalancer.ingress[0].hostname}' 2>/dev/null || echo "Not available yet")

if [ "$ALB_URL" != "Not available yet" ]; then
    echo ""
    echo "🎉 Application is accessible at: http://$ALB_URL"
    echo ""
else
    echo ""
    echo "⏳ ALB is being provisioned. Check back in a few minutes with:"
    echo "   kubectl get ingress -n $NAMESPACE"
    echo ""
fi

echo "To monitor the deployment:"
echo "  kubectl get pods -n $NAMESPACE -w"
echo ""
