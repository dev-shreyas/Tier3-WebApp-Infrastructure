terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~>6.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~>2.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~>2.0"
    }
  }
}

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

provider "aws" {
  region = data.terraform_remote_state.dev.outputs.region
}

# Get EKS cluster information
data "aws_eks_cluster" "cluster" {
  name = data.terraform_remote_state.dev.outputs.cluster_name
}

data "aws_eks_cluster_auth" "cluster" {
  name = data.terraform_remote_state.dev.outputs.cluster_name
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.cluster.token
}

provider "helm" {
  kubernetes {
    host                   = data.aws_eks_cluster.cluster.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority[0].data)
    token                  = data.aws_eks_cluster_auth.cluster.token
  }
}
