# create ecr

resource "aws_ecr_repository" "main" {
  name                 = "${var.app_name}-${var.app_env}-ecr"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Name        = "${var.app_name}-repo"
    Environment = var.app_env
  }
}