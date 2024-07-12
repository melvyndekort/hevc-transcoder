data "aws_iam_policy_document" "hevc" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["s3.amazonaws.com"]
    }

    actions   = ["sqs:SendMessage"]
    resources = [aws_sqs_queue.hevc.arn]

    condition {
      test     = "ArnEquals"
      variable = "aws:SourceArn"
      values   = [aws_s3_bucket.hevc.arn]
    }
  }
}

resource "aws_sqs_queue" "hevc" {
  name = "hevc"

  visibility_timeout_seconds = 7200

  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.hevc_dlq.arn
    maxReceiveCount     = 10
  })
}

resource "aws_sqs_queue_policy" "hevc" {
  queue_url = aws_sqs_queue.hevc.id
  policy    = data.aws_iam_policy_document.hevc.json
}

resource "aws_sqs_queue" "hevc_dlq" {
  name = "hevc-dlq"
}

resource "aws_sqs_queue_redrive_allow_policy" "hevc_dlq" {
  queue_url = aws_sqs_queue.hevc_dlq.id

  redrive_allow_policy = jsonencode({
    redrivePermission = "byQueue",
    sourceQueueArns   = [aws_sqs_queue.hevc.arn]
  })
}

locals {
  alarm_topic_arn = data.terraform_remote_state.cloudsetup.outputs.alerting_sns_arn
}

resource "aws_cloudwatch_metric_alarm" "hevc_dlq_alarm" {
  alarm_name          = "hevc_dlq_alarm"
  statistic           = "Sum"
  metric_name         = "ApproximateNumberOfMessagesVisible"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  threshold           = 1
  period              = 600
  evaluation_periods  = 2
  namespace           = "AWS/SQS"
  dimensions = {
    QueueName = aws_sqs_queue.hevc_dlq.name
  }
  alarm_actions = [local.alarm_topic_arn]
  ok_actions    = [local.alarm_topic_arn]
}
