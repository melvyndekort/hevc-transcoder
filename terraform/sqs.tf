data "aws_iam_policy_document" "queue" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["s3.amazonaws.com"]
    }

    actions   = ["sqs:SendMessage"]
    resources = ["arn:aws:sqs:*:*:hevc"]

    condition {
      test     = "ArnEquals"
      variable = "aws:SourceArn"
      values   = [aws_s3_bucket.hevc.arn]
    }
  }
}

resource "aws_sqs_queue" "hevc" {
  name   = "hevc"
  policy = data.aws_iam_policy_document.queue.json

  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.hevc_dlq.arn
    maxReceiveCount     = 4
  })
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
