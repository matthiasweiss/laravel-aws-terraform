resource "aws_security_group" "alb_sg" {
  vpc_id = aws_vpc.default_vpc.id
}

resource "aws_lb" "alb" {
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = [aws_subnet.public_subnet_az_a.id, aws_subnet.public_subnet_az_b.id]
}

resource "aws_security_group_rule" "alb_allow_outbound" {
  security_group_id = aws_security_group.alb_sg.id
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "all"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "alb_allow_ingress_http" {
  security_group_id = aws_security_group.alb_sg.id
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_lb_listener" "http_listener" {
  load_balancer_arn = aws_lb.alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      message_body = "No associated service found"
      status_code  = "404"
    }
  }
}

resource "aws_lb_listener_rule" "http_listener_rule" {
  listener_arn = aws_lb_listener.http_listener.arn

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.alb_target_group.arn
  }

  condition {
    path_pattern {
      values = ["/*"]
    }
  }
}

resource "aws_lb_target_group" "alb_target_group" {
  depends_on  = [aws_lb.alb]
  port        = 80
  protocol    = "HTTP"
  vpc_id      = aws_vpc.default_vpc.id
  target_type = "ip"

  health_check {
    timeout  = 10
    interval = 15
    path     = "/"
    protocol = "HTTP"
    matcher  = "200-404"
  }
}
