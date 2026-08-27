resource "aws_lb" "internal_alb" {
  name               = "app-tier-internal-alb"
  internal           = true # Critical: This keeps it private, as per the diagram
  load_balancer_type = "application"
  security_groups    = [aws_security_group.internal_alb_sg.id]
  subnets            = [aws_subnet.private_app_az1.id, aws_subnet.private_app_az2.id]
}

resource "aws_lb_target_group" "app_tg" {
  name     = "app-tier-tg"
  port     = 8080
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id
}

resource "aws_lb_listener" "internal_listener" {
  load_balancer_arn = aws_lb.internal_alb.arn
  port              = "80"
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app_tg.arn
  }
}