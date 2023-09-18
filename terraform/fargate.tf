resource "aws_ecs_task_definition" "hevc_encoder" {
  family                   = "hevc-encoder"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = 1024
  memory                   = 2048
  execution_role_arn       = aws_iam_role.hevc_fargate.arn
  
  container_definitions = jsonencode([
    {
      name      = "hevc-encoder"
      image     = "${aws_ecr_repository.hevc_encoder.repository_url}:LATEST"
      cpu       = 1024
      memory    = 2048
      essential = true
    }
  ])
  
  runtime_platform {
    cpu_architecture = "ARM64"
  }
}
