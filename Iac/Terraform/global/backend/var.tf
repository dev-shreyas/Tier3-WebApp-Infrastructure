variable "region" {
  description = "The AWS region to deploy the infrastructure"
  default     = "ap-southeast-2"
}

variable "bucket_name" {
  description = "The name of the S3 bucket for Terraform state"
  default     = "flaskapp.tfstate"
}

variable "lock_table" {
    description = "The name of the DynamoDB table for Terraform state locking"
    default     = "tfstate-locks"
}