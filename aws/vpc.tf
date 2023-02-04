# VPC with two subnet public/private

# terraform.tfvars
/* 
name = "" # Name of the usage
env = "" # Staging, production or testing
*/

########## Enviroment Variable ##########
variable "name" {
  type     = string
  nullable = false
}

variable "env" {
  type     = string
  nullable = false
}

########## Create VPC ##########
resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16" # vpc cidr block
  instance_tenancy     = "default"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "${var.name}-vpc"
    env  = var.env
  }
}

########## Internate gateway ##########
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id # attach to vpc automatically

  tags = {
    Name = "${var.name}-igw"
    env  = var.env
  }
}

########## Create Subnets ##########
resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24" # subnet cidr block
  map_public_ip_on_launch = true

  tags = {
    Name = "public-subnet"
    env  = var.env
  }
}

resource "aws_subnet" "private" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.2.0/24" # subnet cidr block

  tags = {
    Name = "private-subnet"
    env  = var.env
  }
}

########## Modify route table ##########
resource "aws_default_route_table" "public" { # Do not modify default route table
  default_route_table_id = aws_vpc.main.default_route_table_id
  route                  = []

  tags = {
    Name = "default"
    env  = var.env
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
    env  = var.env
  }
}

resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id
  route  = []

  tags = {
    Name = "private-route"
    env  = var.env
  }
}

resource "aws_route_table_association" "private" {
  subnet_id      = aws_subnet.private.id
  route_table_id = aws_route_table.private.id
}
