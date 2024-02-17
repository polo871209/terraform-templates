locals {
  name = "${var.environment}-${var.project}"
  common_tags = {
    Terraform   = "True"
    project     = var.project
    environment = var.environment
  }
}
