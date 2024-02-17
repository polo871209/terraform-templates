terraform {
  required_version = ">= 1.7.3"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.36"
    }
  }
}

provider "aws" {
  region  = var.aws_region
  profile = var.aws_profile
}

module "vpc" {
  source   = "./vpc"
  vpc_name = local.name
  tags     = local.common_tags
}

module "eks" {
  depends_on         = [module.vpc]
  source             = "./eks"
  cluster_name       = local.name
  vpc_public_subnets = module.vpc.public_subnets
  tags               = local.common_tags
}
