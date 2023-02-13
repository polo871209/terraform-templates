terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

terraform {
  backend "s3" {
    bucket = "po-tfstate-test"
    key    = "ap-northeast-3.tfstate"
    region = "ap-northeast-3"
  }
}

provider "aws" {
  region  = "ap-northeast-3"
  profile = "po-netron"
}

module "ecs-module" {
  source  = "./ecs-module"
  app_name           = "po-test" # Name of the usage
  app_env            = "staging" # Staging, production or testing
  region             = "ap-northeast-3"
  availability_zones = ["ap-northeast-3a", "ap-northeast-3b"] # az in list format
  public_subnets     = ["10.0.1.0/24", "10.0.2.0/24"]         # private subnet cidr range in list format
  private_subnets    = ["10.0.3.0/24", "10.0.4.0/24"]         # public subnet cidr range in list format  
  container_port     = "8080"
}
