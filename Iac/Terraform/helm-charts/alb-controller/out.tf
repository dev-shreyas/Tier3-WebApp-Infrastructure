output "alb_controller_role_arn" {
  description = "ARN of the ALB controller IAM role"
  value       = aws_iam_role.alb_controller.arn
}

output "alb_controller_role_name" {
  description = "Name of the ALB controller IAM role"
  value       = aws_iam_role.alb_controller.name
}

output "alb_controller_policy_arn" {
  description = "ARN of the ALB controller IAM policy"
  value       = aws_iam_policy.alb_controller.arn
}

output "alb_helm_release_status" {
  description = "Status of ALB Helm release"
  value       = helm_release.alb_controller.status
}

output "alb_helm_release_version" {
  description = "Version of ALB Helm release deployed"
  value       = helm_release.alb_controller.version
}

output "alb_service_account_name" {
  description = "Service account name for ALB controller"
  value       = kubernetes_service_account_v1.alb_controller.metadata[0].name
}
