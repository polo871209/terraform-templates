# VPC with mutiple subnet public/private

########## Create VPC ##########
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  instance_tenancy     = "default"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name        = "${var.app_name}-vpc"
    Environment = var.app_env
  }
}

########## Internate gateway ##########
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id # attach to vpc automatically

  tags = {
    Name        = "${var.app_name}-igw"
    Environment = var.app_env
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
    Name        = "public-subnet-${count.index + 1}"
    Environment = var.app_env
  }
}

resource "aws_subnet" "private" {
  vpc_id            = aws_vpc.main.id
  count             = length(var.private_subnets)
  cidr_block        = element(var.private_subnets, count.index)
  availability_zone = element(var.availability_zones, count.index)

  tags = {
    Name        = "private-subnet-${count.index + 1}"
    Environment = var.app_env
  }
}

########## Modify route table ##########
resource "aws_default_route_table" "public" { # Do not modify default route table
  default_route_table_id = aws_vpc.main.default_route_table_id
  route                  = []

  tags = {
    Name        = "${var.app_name}-vpc-default"
    Environment = var.app_env
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name        = "${var.app_name}-public"
    Environment = var.app_env
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
    Name = "${var.app_name}-private"
    env  = var.app_env
  }
}

resource "aws_route_table_association" "private" {
  count          = length(var.private_subnets)
  subnet_id      = element(aws_subnet.private.*.id, count.index)
  route_table_id = aws_route_table.private.id
}