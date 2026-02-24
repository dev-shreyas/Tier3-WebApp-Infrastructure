data "aws_eks_cluster" "cluster" {
  name = data.aws_eks_cluster.cluster.name
}

data "aws_eks_cluster_auth" "cluster" {
  name = data.aws_eks_cluster_auth.cluster.name
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