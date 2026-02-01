# Observability Module - Outputs

output "cloudwatch_log_group_name" {
  description = "Name of the CloudWatch Log Group for EKS"
  value       = aws_cloudwatch_log_group.eks_cluster.name
}

output "cloudwatch_log_group_arn" {
  description = "ARN of the CloudWatch Log Group for EKS"
  value       = aws_cloudwatch_log_group.eks_cluster.arn
}

output "cloudwatch_observability_role_arn" {
  description = "ARN of the IAM role for CloudWatch Observability"
  value       = aws_iam_role.cloudwatch_observability.arn
}

output "cloudwatch_addon_id" {
  description = "ID of the CloudWatch Observability add-on"
  value       = aws_eks_addon.cloudwatch_observability.id
}
