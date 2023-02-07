# VPC with two subnet public/private

# terraform.tfvars
/* 
app_name = "" # Name of the usage
app_env = "" # Staging, production or testing
availability_zones = [] # List of availability zones
public_subnets = [] # List of public subnets
private_subnets = [] # List of public subnets
*/

# variables.tf
/*
variable "app_name" {
  type     = string
  nullable = false
}

variable "app_env" {
  type     = string
  nullable = false
}

variable "vpc_cidr" {
  type    = string
  default = "10.0.0.0/16"
}

variable "availability_zones" {
  type        = list(any)
}

variable "public_subnets" {
  type        = list(any)
}

variable "private_subnets" {
  type        = list(any)
}
*/

########## Create VPC ##########
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  instance_tenancy     = "default"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "${var.app_name}-vpc"
    env  = var.app_env
  }
}

########## Internate gateway ##########
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id # attach to vpc automatically

  tags = {
    Name = "${var.app_name}-igw"
    env  = var.app_env
  }
}

########## Create Subnets ##########
resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  count                   = length(var.public_subnets)
  cidr_block              = element(var.public_subnets, count.index)
  availability_zone       = element(var.availability_zones, count.index)
  map_public_ip_on_launch = true

  tags = {
    Name = "public-subnet-${count.index + 1}"
    env  = var.app_env
  }
}

resource "aws_subnet" "private" {
  vpc_id            = aws_vpc.main.id
  count             = length(var.private_subnets)
  cidr_block        = element(var.private_subnets, count.index)
  availability_zone = element(var.availability_zones, count.index)

  tags = {
    Name = "private-subnet-${count.index + 1}"
    env  = var.app_env
  }
}

########## Modify route table ##########
resource "aws_default_route_table" "public" { # Do not modify default route table
  default_route_table_id = aws_vpc.main.default_route_table_id
  route                  = []

  tags = {
    Name = "default"
    env  = var.app_env
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name = "public-route"
    env  = var.app_env
  }
}

resource "aws_route_table_association" "public" {
  count          = length(var.public_subnets)
  subnet_id      = element(aws_subnet.public.*.id, count.index)
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id
  route  = []

  tags = {
    Name = "private-route"
    env  = var.app_env
  }
}

resource "aws_route_table_association" "private" {
  count          = length(var.private_subnets)
  subnet_id      = element(aws_subnet.private.*.id, count.index)
  route_table_id = aws_route_table.private.id
}
