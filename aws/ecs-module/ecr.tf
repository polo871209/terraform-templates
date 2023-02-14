# create ecr

resource "aws_ecr_repository" "ecr" {
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

resource "aws_ecr_repository_policy" "policy" {
  repository = aws_ecr_repository.ecr.name
  policy  = <<POLICY
  {
      "Version": "2008-10-17",
      "Statement": [
          {
              "Sid": "allow-ecs",
              "Effect": "Allow",
              "Principal": {
                "AWS": "${aws_iam_role.ecsTaskExecutionRole.arn}"
                },
              "Action": [
                  "ecr:GetDownloadUrlForLayer",
                  "ecr:BatchGetImage",
                  "ecr:BatchCheckLayerAvailability",
                  "ecr:PutImage",
                  "ecr:InitiateLayerUpload",
                  "ecr:UploadLayerPart",
                  "ecr:CompleteLayerUpload",
                  "ecr:DescribeRepositories",
                  "ecr:GetRepositoryPolicy",
                  "ecr:ListImages",
                  "ecr:DeleteRepository",
                  "ecr:BatchDeleteImage",
                  "ecr:SetRepositoryPolicy",
                  "ecr:DeleteRepositoryPolicy"
              ]
          }
      ]
  }
  POLICY
}

