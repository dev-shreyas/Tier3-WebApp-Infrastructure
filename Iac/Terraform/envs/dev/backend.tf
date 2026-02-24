terraform {
  backend "s3" {
    bucket = "tf-state-managed-bucket-flaskapp"
    key = "dev/eks/terraform.tfstate"
    region = "ap-southeast-2"
    use_lockfile = true
  }
}