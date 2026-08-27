# Web Tier SG (Normally allows traffic from external ALB, omitted here)
resource "aws_security_group" "web_sg" {
  name   = "web-tier-sg"
  vpc_id = aws_vpc.main.id
}

# Internal ALB SG (Allows traffic ONLY from Web Tier)
resource "aws_security_group" "internal_alb_sg" {
  name   = "internal-alb-sg"
  vpc_id = aws_vpc.main.id

  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.web_sg.id]
  }
}

# App Tier SG (Allows traffic ONLY from Internal ALB)
resource "aws_security_group" "app_sg" {
  name   = "app-tier-sg"
  vpc_id = aws_vpc.main.id

  ingress {
    from_port       = 8080
    to_port         = 8080
    protocol        = "tcp"
    security_groups = [aws_security_group.internal_alb_sg.id]
  }
}

# DB Tier SG (Allows traffic ONLY from App Tier)
resource "aws_security_group" "db_sg" {
  name   = "db-tier-sg"
  vpc_id = aws_vpc.main.id

  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.app_sg.id]
  }
}