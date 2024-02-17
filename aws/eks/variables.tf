variable "project" {
  type    = string
  default = "terraform"
}

variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "aws_profile" {
  type    = string
  default = "default"
}

variable "environment" {
  type    = string
  default = "dev"
}
