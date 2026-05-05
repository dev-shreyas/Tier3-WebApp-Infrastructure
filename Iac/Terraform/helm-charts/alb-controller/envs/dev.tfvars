# ALB Controller Configuration - Dev Environment
# NOTE: region, cluster_name, and vpc_id are now automatically fetched from the dev environment Terraform state (terraform_remote_state data source)
# These variables below are kept for reference but will be overridden by remote state values

# region               = "ap-south-1"           # Override: Uses data.terraform_remote_state.dev.outputs.region
# cluster_name         = "flaskapp-eks-cluster" # Override: Uses data.terraform_remote_state.dev.outputs.cluster_name
# vpc_id               = "vpc-05f4199678fcdf2ea"# Override: Uses data.terraform_remote_state.dev.outputs.vpc_id
environment              = "dev"
alb_controller_namespace = "kube-system"
alb_sa_name              = "aws-load-balancer-controller"
//alb_helm_version     = "2.8.0"
