# ===== Remote State Data Source for Dev Environment =====
data "terraform_remote_state" "dev" {
  backend = "s3"
  config = {
    bucket         = "infras-mgmt.tfstate"
    key            = "dev/mgmt/Infrastructure.tfstate"
    region         = "ap-south-1"
    encrypt        = true
    dynamodb_table = "tfstate-locks"
  }
}

# ===== AWS EKS Cluster Data Source =====
data "aws_eks_cluster" "cluster" {
  name = data.terraform_remote_state.dev.outputs.cluster_name
}

# ===== ALB Controller IAM Resources =====

data "aws_caller_identity" "current" {}

# Create OIDC provider if it doesn't exist
data "aws_iam_openid_connect_provider" "eks" {
  url = data.aws_eks_cluster.cluster.identity[0].oidc[0].issuer
}

# IAM Policy for ALB Controller
resource "aws_iam_policy" "alb_controller" {
  name        = "AWSLoadBalancerControllerIAMPolicy-${var.environment}"
  description = "IAM policy for ALB controller in ${var.environment} environment"
  policy      = file("${path.module}/alb_iam_policy.json")

  tags = {
    Name        = "alb-controller-policy"
    Environment = var.environment
  }
}

# IAM Role for ALB Controller with IRSA
resource "aws_iam_role" "alb_controller" {
  name               = "alb-controller-role-${var.environment}"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Federated = data.aws_iam_openid_connect_provider.eks.arn
      }
      Action = "sts:AssumeRoleWithWebIdentity"
      Condition = {
        StringEquals = {
          "${replace(data.aws_eks_cluster.cluster.identity[0].oidc[0].issuer, "https://", "")}:sub" = "system:serviceaccount:${var.alb_controller_namespace}:${var.alb_sa_name}",
          "${replace(data.aws_eks_cluster.cluster.identity[0].oidc[0].issuer, "https://", "")}:aud" = "sts.amazonaws.com"
        }
      }
    }]
  })

  tags = {
    Name        = "alb-controller-role"
    Environment = var.environment
  }
}

# Attach policy to role
resource "aws_iam_role_policy_attachment" "alb_controller" {
  role       = aws_iam_role.alb_controller.name
  policy_arn = aws_iam_policy.alb_controller.arn
}

# ===== Kubernetes Service Account =====

# Reference existing kube-system namespace (system namespace always exists)
data "kubernetes_namespace_v1" "alb_system" {
  metadata {
    name = var.alb_controller_namespace
  }
}

resource "kubernetes_service_account_v1" "alb_controller" {
  metadata {
    name      = var.alb_sa_name
    namespace = data.kubernetes_namespace_v1.alb_system.metadata[0].name

    annotations = {
      "eks.amazonaws.com/role-arn" = aws_iam_role.alb_controller.arn
    }
  }
}

# ===== Helm Release for ALB Controller =====

resource "helm_release" "alb_controller" {
  name       = "aws-load-balancer-controller"
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"
  namespace  = var.alb_controller_namespace
  //version    = var.alb_helm_version
  
  # Increase timeout for slow cluster environments
  timeout = 600 # 10 minutes in seconds
  wait    = true

  values = [
    yamlencode({
      clusterName = data.terraform_remote_state.dev.outputs.cluster_name
      region      = data.terraform_remote_state.dev.outputs.region
      vpcId       = data.terraform_remote_state.dev.outputs.vpc_id
      serviceAccount = {
        create = false
        name   = kubernetes_service_account_v1.alb_controller.metadata[0].name
      }
      replicaCount = 2
      resources = {
        limits = {
          cpu    = "200m"
          memory = "256Mi"
        }
        requests = {
          cpu    = "100m"
          memory = "128Mi"
        }
      }
      # Removed nodeSelector to allow pod scheduling on any node
      # If you need to restrict to specific nodes, ensure the labels exist
    })
  ]

  depends_on = [kubernetes_service_account_v1.alb_controller]

  lifecycle {
    ignore_changes = [values]
  }
}
