locals {
  log_configuration = var.enable_logging ? {
    logDriver = "awslogs"
    options = {
      awslogs-group         = "ecs-default",
      awslogs-region        = "eu-west-1",
      awslogs-create-group  = "false",
      awslogs-stream-prefix = "hevc-encoder"
    }
  } : null
}

resource "aws_ecs_task_definition" "hevc_encoder" {
  family                   = "hevc-encoder"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = 2048
  memory                   = 4096
  execution_role_arn       = aws_iam_role.hevc_fargate.arn

  container_definitions = jsonencode([
    {
      name             = "hevc-encoder"
      image            = "registry.ipv6.docker.com/melvyndekort/hevc-encoder:latest"
      essential        = true
      logConfiguration = local.log_configuration
    }
  ])

  runtime_platform {
    cpu_architecture = "ARM64"
  }
}

resource "aws_security_group" "hevc_encoder" {
  name        = "hevc-encoder"
  description = "hevc-encoder"
  vpc_id      = data.terraform_remote_state.cloudsetup.outputs.vpc_id

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "hevc-encoder"
  }
}
