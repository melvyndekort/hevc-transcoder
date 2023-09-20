resource "aws_cloudwatch_event_rule" "s3_upload_mp4" {
  name        = "capture-mp4-upload-events"
  description = "Capture all upload events of mp4 files in an S3 bucket"

  event_pattern = jsonencode({
    source      = [ "aws.s3" ],
    detail-type = [ "Object Created" ],
    detail = {
      bucket = {
        name = [ aws_s3_bucket.hevc.id ]
      }
      object = {
        key = [ { prefix = "TODO/" } ]
      }
    }
  })
}

resource "aws_cloudwatch_event_target" "fargate_hevc_encoder" {
  target_id = "fargate-hevc-encoder"
  rule      = aws_cloudwatch_event_rule.s3_upload_mp4.name
  arn       = data.terraform_remote_state.cloudsetup.outputs.ecs_cluster_arn
  role_arn  = aws_iam_role.eventbridge_fargate.arn

  ecs_target {
    task_count          = 1
    task_definition_arn = aws_ecs_task_definition.hevc_encoder.arn
    launch_type         = "FARGATE"

    network_configuration {
      subnets          = data.terraform_remote_state.cloudsetup.outputs.public_subnets
      security_groups  = [aws_security_group.hevc_encoder.id]
      assign_public_ip = var.enable_logging
    }
  }

  input_transformer {
    input_paths = {
      bucketname = "$.detail.bucket.name",
      objectkey  = "$.detail.object.key",
    }

    input_template = <<EOF
{
  "containerOverrides": [
    {
      "name": "hevc-encoder",
      "environment": [
        { "name": "S3_BUCKET_NAME", "value": "<bucketname>" },
        { "name": "S3_OBJECT_KEY", "value": "<objectkey>" }
      ]
    }
  ]
}
EOF
  }
}
