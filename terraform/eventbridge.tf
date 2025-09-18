resource "aws_pipes_pipe" "hevc_transcoder" {
  name     = "hevc-transcoder"
  role_arn = aws_iam_role.eventbridge_fargate.arn
  source   = aws_sqs_queue.hevc.arn
  target   = data.terraform_remote_state.tf_aws.outputs.ecs_cluster_arn

  target_parameters {
    ecs_task_parameters {
      task_count          = 1
      task_definition_arn = aws_ecs_task_definition.hevc_transcoder.arn

      network_configuration {
        aws_vpc_configuration {
          subnets          = data.terraform_remote_state.tf_aws.outputs.public_subnets
          security_groups  = [aws_security_group.hevc_transcoder.id]
          assign_public_ip = var.enable_logging ? "ENABLED" : "DISABLED"
        }
      }

      capacity_provider_strategy {
        capacity_provider = "FARGATE_SPOT"
        weight            = 1
      }

      overrides {
        container_override {
          name = "hevc-transcoder"

          # Workaround: Terraform sets these to 0 if they're unset
          cpu                = (var.cpu - 1)
          memory             = (var.memory - 1)
          memory_reservation = (var.memory - 1)

          environment {
            name  = "S3_BUCKET_NAME"
            value = "$.body.Records[0].s3.bucket.name"
          }

          environment {
            name  = "S3_OBJECT_KEY"
            value = "$.body.Records[0].s3.object.key"
          }
        }
      }
    }
  }
}

resource "aws_cloudwatch_event_rule" "ecs_status" {
  name        = "ecs-status"
  description = "Capture event emitted by ECS"

  event_pattern = jsonencode({
    source      = ["aws.ecs"]
    detail-type = ["ECS Task State Change"]
    detail = {
      lastStatus = [
        "RUNNING",
        "STOPPED"
      ]
    }
  })
}

resource "aws_cloudwatch_event_target" "ecs_status" {
  rule = aws_cloudwatch_event_rule.ecs_status.name
  arn  = data.terraform_remote_state.cloudsetup.outputs.notifications_sns_arn
}
