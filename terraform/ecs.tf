# Look up the standard ECS task execution role policy (AWS-managed, already exists)
data "aws_iam_policy" "ecs_execution" {
  arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# The IAM execution role — lets ECS pull the image from ECR and write logs
resource "aws_iam_role" "ecs_execution" {
  name = "config-validator-ecs-execution-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name = "config-validator-ecs-execution-role"
  }
}

# Attach the AWS-managed permissions to our role
resource "aws_iam_role_policy_attachment" "ecs_execution" {
  role       = aws_iam_role.ecs_execution.name
  policy_arn = data.aws_iam_policy.ecs_execution.arn
}

# The ECS cluster — the "home" where the container runs
resource "aws_ecs_cluster" "main" {
  name = "config-validator-cluster"

  tags = {
    Name = "config-validator-cluster"
  }
}

# The task definition — the "recipe" for running the container
resource "aws_ecs_task_definition" "main" {
  family                   = "config-validator-task"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = aws_iam_role.ecs_execution.arn

  container_definitions = jsonencode([
    {
      name      = "config-validator"
      image     = "276429521380.dkr.ecr.eu-west-2.amazonaws.com/config-validator:0.1"
      essential = true
      portMappings = [
        {
          containerPort = 8000
          protocol      = "tcp"
        }
      ]
    }
  ])

  tags = {
    Name = "config-validator-task"
  }
}