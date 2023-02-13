# alb
resource "aws_security_group" "alb-sg" {
  vpc_id = aws_vpc.main.id

  ingress {
    from_port        = var.container_port
    to_port          = var.container_port
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
  tags = {
    Name        = "${var.app_name}-alb-sg"
    Environment = var.app_env
  }
}

resource "aws_alb" "main" {
  name               = "${var.app_name}-${var.app_env}-alb"
  internal           = false
  load_balancer_type = "application"
  subnets            = aws_subnet.public.*.id
  security_groups    = [aws_security_group.alb-sg.id]

  tags = {
    Name        = "${var.app_name}-alb"
    Environment = var.app_env
  }
}

resource "aws_lb_target_group" "target_group" {
  name        = "${var.app_name}-${var.app_env}-tg"
  port        = var.container_port
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = aws_vpc.main.id

  #   health_check {
  #     healthy_threshold   = "3"
  #     interval            = "300"
  #     protocol            = "HTTP"
  #     matcher             = "200"
  #     timeout             = "3"
  #     path                = "/v1/status"
  #     unhealthy_threshold = "2"
  #   }

  tags = {
    Name        = "${var.app_name}-alb-tg"
    Environment = var.app_env
  }
}

resource "aws_lb_listener" "listener" {
  load_balancer_arn = aws_alb.main.id
  port              = var.container_port
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.target_group.id
  }
}