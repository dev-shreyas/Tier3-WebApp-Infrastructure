variable "cluster_name" {
  description = "Name of cluster"
  type = string
}

variable "region" {
  description = "AWS region"
  type = string
  default = "ap-southeast-2"
}

variable "vpc_id" {
  description = "VPC ID"
  type = string
  default = "10.0.0.0/16"
}