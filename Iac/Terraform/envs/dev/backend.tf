terraform {
  backend "s3" {
    bucket         = "infra-mgmt.tfstate"
    key            = "dev/mgmt/Infrastructure.tfstate"
    region         = "ap-south-1"
    dynamodb_table = "tfstate-locks"
    use_lockfile   = true
  }
}