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
  region = "ap-southeast-2"
}

provider "helm" {
  kubernetes = {
    config_path = "~/.kube/config"
    host = module.aws_managed_eks.cluster_endpoint
    cluster_ca_certificate = base64decode(module.aws_managed_eks.cluster_certificate_authority_data)
    token = data.aws_eks_cluster_auth.cluster.token
  }
}

provider "kubernetes" {
  host = module.aws_managed_eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.aws_managed_eks.cluster_certificate_authority_data)
  token = data.aws_eks_cluster_auth.cluster.token  
}