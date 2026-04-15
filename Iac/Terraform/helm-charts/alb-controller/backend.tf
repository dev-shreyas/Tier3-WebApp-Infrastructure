terraform {
  backend "s3" {
    bucket         = "flaskapp-terraform-state"
    key            = "helm-charts/alb-controller/terraform.tfstate"
    region         = "ap-south-1"
    encrypt        = true
    dynamodb_table = "terraform-locks"
  }
}
