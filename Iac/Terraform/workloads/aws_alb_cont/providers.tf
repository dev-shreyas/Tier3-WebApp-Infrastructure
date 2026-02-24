data "aws_eks_cluster" "cluster" {
  name = module.aws_managed_eks.cluster_name
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.aws_managed_eks.cluster_name
}

provider "kubernetes" {
  host = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64encode(
    data.aws_eks_cluster_auth.cluster.token
  )
}

provider "helm" {
  kubernetes = {
    host = data.aws_eks_cluster.cluster.endpoint
    cluster_ca_certificate = base64encode(
      data.aws_eks_cluster.cluster_certificate_authority[0].data
    )
    token = data.aws_eks_cluster_auth.cluster.token
  }
}