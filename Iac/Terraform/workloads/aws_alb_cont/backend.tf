terraform {
  backend "s3" {
    bucket = "workloads.tfstate"
    key    = "dev/workloads/terraform.tfstate"
    region = "ap-southeast-2"
    use_lockfile = true
    dynamodb_table = "tfstate-locks"
    encrypt = true
  }
}