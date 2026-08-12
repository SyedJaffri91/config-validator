# Security group for the load balancer — allows web traffic from anyone
resource "aws_security_group" "alb" {
  name        = "config-validator-alb-sg"
  description = "Allow web traffic to the load balancer"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "Allow HTTP from anywhere"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "config-validator-alb-sg"
  }
}

# Security group for the container — only allows traffic from the load balancer
resource "aws_security_group" "task" {
  name        = "config-validator-task-sg"
  description = "Allow traffic from the load balancer only"
  vpc_id      = aws_vpc.main.id

  ingress {
    description     = "Allow port 8000 from the load balancer only"
    from_port       = 8000
    to_port         = 8000
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
  }

  egress {
    description = "Allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "config-validator-task-sg"
  }
}