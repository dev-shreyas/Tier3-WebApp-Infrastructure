# ALB Controller Configuration - Prod Environment

region               = "ap-south-1"
cluster_name         = "flaskapp-eks-cluster-prod"
vpc_id               = "10.2.0.0/16"
environment          = "prod"
alb_controller_namespace = "kube-system"
alb_sa_name          = "aws-load-balancer-controller"
alb_helm_version     = "2.6.2"
