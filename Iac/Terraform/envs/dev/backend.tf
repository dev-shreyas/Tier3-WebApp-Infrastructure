terraform {
  backend "s3" {
    bucket = "flaskapp.tfstate"
    key = "dev/mgmt/terraform.tfstate"
    region = "ap-southeast-2"
    dynamodb_table = "tfstate-locks"
    use_lockfile = true
  }
}