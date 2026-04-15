# ALB Controller Configuration - UAT Environment

region               = "ap-south-1"
cluster_name         = "flaskapp-eks-cluster-uat"
vpc_id               = "10.1.0.0/16"
environment          = "uat"
alb_controller_namespace = "kube-system"
alb_sa_name          = "aws-load-balancer-controller"
alb_helm_version     = "2.6.2"
