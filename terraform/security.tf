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


  tags = {
    Name = "config-validator-alb-sg"
  }
}

# Security group for the container — only allows traffic from the load balancer
#trivy:ignore:AWS-0104 Task needs open egress to reach ECR/CloudWatch; scoping properly requires VPC endpoints (no NAT gateway in this design). Accepted 2026-08-18.
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


# ALB egress — scoped to the task SG (separate resource to avoid a dependency cycle)
resource "aws_security_group_rule" "alb_egress_to_task" {
  type                     = "egress"
  from_port                = 8000
  to_port                  = 8000
  protocol                 = "tcp"
  security_group_id        = aws_security_group.alb.id
  source_security_group_id = aws_security_group.task.id
  description              = "Allow outbound only to the task security group"
}