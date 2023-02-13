variable "region" {
  type     = string
  nullable = false
}

variable "availability_zones" {
  type     = list(string)
  nullable = false
}

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

variable "public_subnets" {
  type    = list(string)
  default = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnets" {
  type    = list(string)
  default = ["10.0.3.0/24", "10.0.4.0/24"]
}

variable "container_port" {
  type    = string
  default = "80"
}