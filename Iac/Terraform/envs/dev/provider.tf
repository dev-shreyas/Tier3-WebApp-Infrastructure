terraform {
  required_providers {
    aws = {
        source = "hashicorp/aws"
        version = "~>6.0"
    }
    helm = {
        source = "hashicorp/helm"
    }
  }
}

provider "aws" {
  region = "ap-south-1"
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.aws_managed_eks.cluster_name
}

provider "kubernetes" {
  host = module.aws_managed_eks.cluster_endpoint
  cluster_ca_certificate = base64decode(
    module.aws_managed_eks.cluster_certificate_authority_data
  )
    token = data.aws_eks_cluster_auth.cluster.token
}

provider "helm" {
  kubernetes = {
    host = module.aws_managed_eks.cluster_endpoint
    cluster_ca_certificate = base64decode(
      module.aws_managed_eks.cluster_certificate_authority_data
    )
    token = data.aws_eks_cluster_auth.cluster.token
  }
}