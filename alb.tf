resource "aws_alb" "main" {
  name            = "cb-load-balancer"
  subnets         = [for subnet in data.aws_subnet.default : subnet.id]
  security_groups = [aws_security_group.my_security_group.id]
  internal        = false
}

resource "aws_alb_target_group" "app" {
  name        = "cb-target-group"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = data.aws_vpc.default.id
  target_type = "ip"

  health_check {
    healthy_threshold   = "3"
    interval            = "30"
    protocol            = "HTTP"
    matcher             = "200"
    timeout             = "3"
    path                = var.health_check_path
    unhealthy_threshold = "2"
  }
}

resource "aws_alb_listener" "listener_http" {
  load_balancer_arn = aws_alb.main.id
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = 443
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

# Redirect all traffic from the ALB to the target group
resource "aws_alb_listener" "front_end" {
  load_balancer_arn = aws_alb.main.id
  port              = "443"
  protocol          = "HTTPS"
  certificate_arn   = aws_acm_certificate.api.arn
  ssl_policy        = "ELBSecurityPolicy-2016-08"


  default_action {
    target_group_arn = aws_alb_target_group.app.id
    type             = "forward"
  }
}
