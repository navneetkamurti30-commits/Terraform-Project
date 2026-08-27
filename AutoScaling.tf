# Web Tier Compute
resource "aws_launch_template" "web_lt" {
  name_prefix   = "web-server-"
  image_id      = "ami-0f863d7d5d7cb63e0" # Generic Amazon Linux 2 AMI
  instance_type = "t2.micro"
  network_interfaces { security_groups = [aws_security_group.web_sg.id] }
}

resource "aws_autoscaling_group" "web_asg" {
  vpc_zone_identifier = [aws_subnet.private_web_az1.id, aws_subnet.private_web_az2.id]
  desired_capacity    = 2
  max_size            = 4
  min_size            = 2

  launch_template {
    id      = aws_launch_template.web_lt.id
    version = "$Latest"
  }
}

# App Tier Compute
resource "aws_launch_template" "app_lt" {
  name_prefix   = "app-server-"
  image_id      = "ami-0f863d7d5d7cb63e0"
  instance_type = "t2.micro"
  network_interfaces { security_groups = [aws_security_group.app_sg.id] }
}

resource "aws_autoscaling_group" "app_asg" {
  vpc_zone_identifier = [aws_subnet.private_app_az1.id, aws_subnet.private_app_az2.id]
  target_group_arns   = [aws_lb_target_group.app_tg.arn]
  desired_capacity    = 2
  max_size            = 4
  min_size            = 2

  launch_template {
    id      = aws_launch_template.app_lt.id
    version = "$Latest"
  }
}