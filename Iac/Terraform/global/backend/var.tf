variable "region" {
  description = "The AWS region to deploy the infrastructure"
  default     = "ap-southeast-2"
}

variable "bucket_name" {
  description = "The name of the S3 bucket for Terraform state"
  default     = "tf-state-managed-bucket-flaskapp"
}

variable "lock_table" {
    description = "The name of the DynamoDB table for Terraform state locking"
    default     = "tf-lock-table"
}