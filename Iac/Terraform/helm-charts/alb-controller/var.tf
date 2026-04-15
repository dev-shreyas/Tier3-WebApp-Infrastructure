variable "region" {
  description = "AWS region"
  type        = string
  default     = "ap-south-1"
}

variable "cluster_name" {
  description = "EKS cluster name"
  type        = string
  default     = "flaskapp-eks-cluster"
}

variable "vpc_id" {
  description = "VPC ID for ALB controller"
  type        = string
  default     = "10.0.0.0/16"
}

variable "environment" {
  description = "Environment name (dev, uat, prod)"
  type        = string
  default     = "dev"
}

variable "alb_controller_namespace" {
  description = "Kubernetes namespace for ALB controller"
  type        = string
  default     = "kube-system"
}

variable "alb_sa_name" {
  description = "Service account name for ALB controller"
  type        = string
  default     = "aws-load-balancer-controller"
}

variable "alb_helm_version" {
  description = "Helm chart version for ALB controller"
  type        = string
  default     = "2.6.2"
}
