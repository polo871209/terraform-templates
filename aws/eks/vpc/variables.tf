variable "vpc_name" {
  type    = string
  default = "vpc"
}

variable "vpc_cidr_block" {
  type    = string
  default = "10.0.0.0/16"
}

variable "vpc_public_subnets" {
  type    = list(string)
  default = ["10.0.101.0/24", "10.0.102.0/24"]
}

variable "vpc_private_subnets" {
  type    = list(string)
  default = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "vpc_database_subnets" {
  type    = list(string)
  default = ["10.0.151.0/24", "10.0.152.0/24"]
}

variable "vpc_create_database_subnet_group" {
  type    = bool
  default = true
}

variable "vpc_create_database_subnet_route_table" {
  type    = bool
  default = true
}

variable "vpc_enable_nat_gateway" {
  type    = bool
  default = true
}

variable "vpc_single_nat_gateway" {
  type    = bool
  default = true
}

variable "tags" {
  type    = map(string)
  default = null
}
