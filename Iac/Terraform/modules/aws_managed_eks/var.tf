variable "cluster_name" {
  description = "The name of the EKS cluster"
  type        = string
  default     = "flaskapp-eks-cluster"
}
variable "kubernetes_version" {
  description = "The Kubernetes version for the EKS cluster"
  type        = string
  default     = "1.34"
}
variable "before_compute_eks_pod_identity_agent" {
  description = "Configuration for before_compute of eks-pod-identity-agent addon"
  type        = bool
  default     = true
}
variable "before_compute_eks_vpc_cni" {
  description = "Configuration for before_compute of vpc-cni addon"
  type        = bool
  default     = true
}
variable "endpoint_public_access" {
  description = "Whether to enable public access for the EKS cluster endpoint"
  type        = bool
  default     = true
}
variable "enable_cluster_creator_admin_permissions" {
  description = "Whether to enable admin permissions for the cluster creator"
  type        = bool
  default     = true
}
variable "node_group_desired_capacity" {
  description = "Desired capacity for the EKS managed node group"
  type        = number
  default     = 2
}
variable "node_group_max_capacity" {
  description = "Maximum capacity for the EKS managed node group"
  type        = number
  default     = 3
}
variable "node_group_min_capacity" {
  description = "Minimum capacity for the EKS managed node group"
  type        = number
  default     = 1
}
variable "node_group_instance_types" {
  description = "Instance types for the EKS managed node group"
  type        = list(string)
  default     = ["t3.medium"]
}
variable "node_group_disk_size" {
  description = "Disk size (in GB) for the EKS managed node group instances"
  type        = number
  default     = 20
}
variable "environment" {
  description = "The environment for tagging purposes"
  type        = string
  default     = "dev"
}
variable "vpc_ids" {
  description = "List of VPC IDs where the EKS cluster will be deployed"
  type        = list(string)
}
variable "subnet_ids" {
  description = "List of Subnet IDs for the EKS cluster"
  type        = list(string)
}

variable "before_compute_eks_metrics_server" {
  description = "Configuration for before_compute of metrics-server addon"
  type        = bool
  default     = true
}

variable "before_compute_eks_external_dns" {
  description = "Configuration for before_compute of external-dns addon"
  type        = bool
  default     = true
}