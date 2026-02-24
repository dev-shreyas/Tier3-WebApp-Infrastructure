resource "helm_release" "alb_controller" {
  name       = "aws-load-balancer-controller"
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"
  namespace  = "kube-system"

  values = [
    yamlencode({
      clusterName = data.aws_eks_cluster.cluster.name
      region      = data.aws_eks_cluster.cluster.region
      vpcId       = data.aws_eks_cluster.cluster.vpc_id
      serviceAccount = {
        create = false
        name   = "aws-load-balancer-controller"
      }
    })
  ]
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