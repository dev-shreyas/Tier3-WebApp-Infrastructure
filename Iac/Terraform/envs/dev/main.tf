module "vpc" {
  source              = "../../modules/aws_vpc"
  vpc_cidr            = "10.0.0.0/16"
  vpc_name            = "flaskapp-eks-vpc"
  vpc_azs             = ["ap-southeast-2a", "ap-southeast-2b", "ap-southeast-2c"]
  vpc_private_subnets = [for i in range(1, 4) : "10.0.${i}.0/24"]
  vpc_public_subnets  = [for i in range(101, 104) : "10.0.${i}.0/24"]
}

module "iam_roles" {
  source      = "../../modules/aws_iam_roles"
  oidc_issuer = module.aws_managed_eks.cluster_oidc_issuer
}

module "aws_managed_eks" {
  source             = "../../modules/aws_managed_eks"
  cluster_name       = "flaskapp-eks-cluster"
  kubernetes_version = "1.34"
  vpc_ids            = [module.vpc.vpc_id]
  subnet_ids         = module.vpc.private_subnets
  environment        = "dev"
}

module "ecr" {
  source          = "../../modules/aws_ecr"
  repository_name = "flaskapp-dev-ecr"
}

module "aws_alb_cont" {
  source       = "../../modules/aws_alb_cont"
  cluster_name = module.aws_managed_eks.cluster_name
  region       = var.region
  vpc_id       = module.vpc.vpc_id

  depends_on = [ module.aws_managed_eks ]
}

resource "kubernetes_service_account_v1" "alb_controller" {
  metadata {
    name      = "aws-load-balancer-controller"
    namespace = "kube-system"

    annotations = {
      "eks.amazonaws.com/role-arn" = module.iam_roles.alb_controller_role_arn
    }
  }
}

data "aws_iam_role" "github_terraform_role" {
  name = "github-terraform-role"
}

resource "aws_eks_access_entry" "github_actions" {
  cluster_name  = module.aws_managed_eks.cluster_name
  principal_arn = data.aws_iam_role.github_terraform_role.arn

  depends_on = [module.aws_managed_eks]
}

resource "aws_eks_access_policy_association" "github_actions_admin" {
  cluster_name  = module.aws_managed_eks.cluster_name
  principal_arn = data.aws_iam_role.github_terraform_role.arn
  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"

  access_scope {
    type = "cluster"
  }
}

# data "aws_iam_user" "current_user" {
#   user_name = "IAMUser1"
# }

# resource "aws_eks_access_entry" "local_admin" {
#   cluster_name  = module.aws_managed_eks.cluster_name
#   principal_arn = "arn:aws:iam::426449772112:user/IAMUser1"
# }

# resource "aws_eks_access_policy_association" "local_admin_policy" {
#   cluster_name  = module.aws_managed_eks.cluster_name
#   principal_arn = "arn:aws:iam::426449772112:user/IAMUser1"
#   policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"

#   access_scope {
#     type = "cluster"
#   }
# }