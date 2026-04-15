terraform {
  backend "s3" {
    bucket         = "helm-charts.tfstate"
    key            = "helm-charts/alb-controller/alb_helm.tfstate"
    region         = "ap-south-1"
    encrypt        = true
    dynamodb_table = "tfstate-locks"
  }
}
