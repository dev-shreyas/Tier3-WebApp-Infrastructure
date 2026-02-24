# resource "aws_launch_template" "eks_nodes" {
#   name_prefix = "flaskapp-nodes"

#   metadata_options {
#     http_tokens               = "required"
#     http_put_response_hop_limit = 2
#     http_endpoint             = "enabled"
#   }
# }

module "eks" {
 source = "terraform-aws-modules/eks/aws"
 version = "~> 21.0"

 name = var.cluster_name
 kubernetes_version = var.kubernetes_version

addons = {
    coredns                = {}
    eks-pod-identity-agent = {
      before_compute = var.before_compute_eks_pod_identity_agent
    }
    kube-proxy             = {}
    vpc-cni                = {
      before_compute = var.before_compute_eks_vpc_cni
    }
    metrics-server        = {
      enabled = true
      before_compute = var.before_compute_eks_metrics_server
    }
    external-dns          = {
      enabled = true
      before_compute = var.before_compute_eks_external_dns
    }
  }
 endpoint_public_access = var.endpoint_public_access
 enable_cluster_creator_admin_permissions = var.enable_cluster_creator_admin_permissions

 vpc_id = var.vpc_ids[0]
 subnet_ids = var.subnet_ids
 control_plane_subnet_ids = var.subnet_ids

 eks_managed_node_groups = {
    flaskapp-nodes = {
      desired_capacity = var.node_group_desired_capacity
      max_capacity     = var.node_group_max_capacity
      min_capacity     = var.node_group_min_capacity

      instance_types = var.node_group_instance_types
      disk_size = var.node_group_disk_size

      # launch_template = {
      #   id = aws_launch_template.eks_nodes.id
      #   version = "$Latest"
      # }

      metadata_options = {
        http_endpoint = "enabled"
        http_put_response_hop_limit = 2
        http_tokens = "required"
      }

      additional_tags = {
        Name = "flaskapp-eks-node-group"
        Project = "flaskapp-eks"
        ENV   = var.environment
      }
    }
  }
}