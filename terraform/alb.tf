# Application Load Balancer
resource "aws_lb" "app" {
  # checkov:skip=CKV_AWS_91: ALB access logging deferred for the cost-conscious demo environment
  # checkov:skip=CKV2_AWS_28: AWS WAF deferred; additional protection and recurring costs are not required for the initial demo
  name                       = "aws-terraform-infra-alb"
  internal                   = false
  load_balancer_type         = "application"
  security_groups            = [aws_security_group.alb.id]
  subnets                    = aws_subnet.public[*].id
  enable_deletion_protection = true
  drop_invalid_header_fields = true


  tags = {
    Name        = "aws-terraform-infra-alb"
    Environment = "dev"
    ManagedBy   = "Terraform"
    Project     = "aws-terraform-infra"
  }
}


# Target Group ECS Fargate tasks
resource "aws_lb_target_group" "app" {
  name        = "aws-terraform-infra-tg"
  port        = 8000
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = aws_vpc.main.id


  health_check {
    enabled             = true
    path                = "/health"
    protocol            = "HTTP"
    port                = "traffic-port"
    matcher             = "200"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 3
  }


  tags = {
    Name        = "aws-terraform-infra-tg"
    Environment = "dev"
    ManagedBy   = "Terraform"
    Project     = "aws-terraform-infra"
  }
}


# HTTP Listener --> redirect all traffic to HTTPS
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.app.arn
  port              = 80
  protocol          = "HTTP"


  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}


resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_lb.app.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS13-1-2-2021-06"
  certificate_arn   = data.aws_acm_certificate.app.arn


  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app.arn
  }
}