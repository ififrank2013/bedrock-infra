# terraform.tfvars - Project Bedrock Configuration

# AWS Configuration
aws_region = "us-east-1"

# Student Information
student_id = "ALT-SOE-025-0275"

# EKS Configuration
cluster_name    = "project-bedrock-cluster"
cluster_version = "1.34"

# Node Group Configuration
node_group_desired_size = 3
node_group_min_size     = 3
node_group_max_size     = 5
# node_instance_types     = ["t3.medium"]
node_instance_types     = ["t3.small"]


# Feature Flags
enable_rds          = true
enable_alb_ingress  = true

# Application Configuration
app_namespace = "retail-app"

# Developer Access
developer_username = "bedrock-dev-view"
