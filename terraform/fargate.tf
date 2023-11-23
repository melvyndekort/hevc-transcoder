locals {
  log_configuration = var.enable_logging ? {
    logDriver = "awslogs"
    options = {
      awslogs-group         = "ecs-default",
      awslogs-region        = "eu-west-1",
      awslogs-stream-prefix = "hevc-transcoder"
    }
  } : null
}

resource "aws_ecs_task_definition" "hevc_transcoder" {
  family                   = "hevc-transcoder"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = 4096
  memory                   = 8192
  execution_role_arn       = aws_iam_role.hevc_fargate_execution.arn
  task_role_arn            = aws_iam_role.hevc_fargate_task.arn

  container_definitions = jsonencode([
    {
      name             = "hevc-transcoder"
      image            = "registry.ipv6.docker.com/melvyndekort/hevc-transcoder:latest"
      command          = ["python", "-m", "hevc_transcoder.transcoder"],
      essential        = true
      logConfiguration = local.log_configuration

      environment = [
        {
          name  = "AWS_USE_DUALSTACK_ENDPOINT"
          value = "true"
        }
      ]
    }
  ])

  runtime_platform {
    cpu_architecture = "ARM64"
  }
}

resource "aws_security_group" "hevc_transcoder" {
  name        = "hevc-transcoder"
  description = "hevc-transcoder"
  vpc_id      = data.terraform_remote_state.cloudsetup.outputs.vpc_id

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "hevc-transcoder"
  }
}
