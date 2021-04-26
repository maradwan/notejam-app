# alb.tf

resource "aws_alb" "main" {
  name            = "${var.name}-${var.env}-load-balancer"
  subnets         = var.subnet_public_id
  security_groups = var.security_group_lb_id
}

resource "aws_alb_target_group" "app" {
  name        = "${var.name}-${var.env}-target-group-1"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"

  health_check {
    healthy_threshold   = "2"
    interval            = "6"
    protocol            = "HTTP"
    matcher             = "302,200"
    timeout             = "5"
    path                = "/"
    unhealthy_threshold = "2"
  }
}

resource "aws_alb_target_group" "app2" {
  name        = "${var.name}-${var.env}-target-group-2"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"

  health_check {
    healthy_threshold   = "2"
    interval            = "6"
    protocol            = "HTTP"
    matcher             = "302,200"
    timeout             = "5"
    path                = "/"
    unhealthy_threshold = "2"
  }
}

# Redirect all traffic from the ALB to the target group
resource "aws_alb_listener" "front_end" {
  load_balancer_arn = aws_alb.main.id
  port              = "80"
  protocol          = "HTTP"


  default_action {
    target_group_arn = aws_alb_target_group.app.id
    type             = "forward"
  }

  lifecycle {
    ignore_changes = [
      default_action
    ]
  }

}