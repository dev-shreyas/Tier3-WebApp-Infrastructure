module "vpc" {
  source = "terraform-aws-modules/vpc/aws"
  version = "6.5.0"

  name = var.vpc_name
  cidr = var.vpc_cidr
  azs             = var.vpc_azs
  private_subnets = var.vpc_private_subnets
  public_subnets  = var.vpc_public_subnets

  map_public_ip_on_launch = true
  enable_nat_gateway = var.enable_nat_gateway
  enable_vpn_gateway = var.enable_vpn_gateway

  tags = {
    "kubernetes.io/cluster/flaskapp-eks-cluster" = "shared"
    "kubernetes.io/role/elb" = "1"
    "kubernetes.io/role/internal-elb" = "1"
  }
}