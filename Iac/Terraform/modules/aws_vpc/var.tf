variable "vpc_name" {
  description = "The name of the VPC"
  default     = "eks-managed-vpc"
}

variable "vpc_cidr" {
  description = "The CIDR block for the VPC"
  default     = "10.0.0.0/16"
}

variable "vpc_azs" {
  description = "The availability zones for the VPC"
  default     = ["us-east-1a", "us-east-1b", "us-east-1c"]
  type = list(string)
}

variable "vpc_private_subnets" {
  description = "The private subnets for the VPC"
  default     = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  type        = list(string)    
}

variable "vpc_public_subnets" {
  description = "The public subnets for the VPC"
  default     = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]
  type        = list(string)
}

variable "enable_nat_gateway" {
  description = "Enable NAT Gateway"
  default     = true
}

variable "enable_vpn_gateway" {
  description = "Enable VPN Gateway"
  default     = true
}