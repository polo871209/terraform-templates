variable "cluster_name" {
  type    = string
  default = "eks"
}

variable "cluster_service_ipv4_cidr" {
  type    = string
  default = null
}

variable "cluster_version" {
  type    = string
  default = null
}

variable "vpc_public_subnets" {
  type    = list(string)
  default = null
}

variable "cluster_endpoint_private_access" {
  type    = bool
  default = false
}

variable "cluster_endpoint_public_access" {
  type    = bool
  default = true
}

variable "cluster_endpoint_public_access_cidrs" {
  type    = list(string)
  default = ["0.0.0.0/0"]
}

variable "nodegroup_instance_type" {
  type    = list(string)
  default = ["t3.small"]
}

variable "tags" {
  type    = map(string)
  default = null
}
