data "aws_availability_zones" "available" {
  state = "available"

  # only az not local zone
  filter {
    name   = "opt-in-status"
    values = ["opt-in-not-required"]
  }
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.5.2"

  name = var.vpc_name
  cidr = var.vpc_cidr_block

  azs             = data.aws_availability_zones.available.names
  private_subnets = var.vpc_public_subnets
  public_subnets  = var.vpc_private_subnets

  enable_nat_gateway = var.vpc_enable_nat_gateway
  single_nat_gateway = var.vpc_single_nat_gateway

  enable_dns_hostnames = true
  enable_dns_support   = true

  database_subnets                   = var.vpc_database_subnets
  create_database_subnet_group       = var.vpc_create_database_subnet_group
  create_database_subnet_route_table = var.vpc_create_database_subnet_route_table

  map_public_ip_on_launch = true

  tags = var.tags
}
