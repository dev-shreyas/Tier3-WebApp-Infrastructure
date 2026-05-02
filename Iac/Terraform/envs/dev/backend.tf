terraform {
  backend "s3" {
    bucket         = "infras-mgmt.tfstate"
    key            = "dev/mgmt/Infrastructure.tfstate"
    region         = "ap-south-1"
    dynamodb_table = "tfstate-locks"
    use_lockfile   = true
  }
}