data "aws_iam_policy_document" "assume_hevc_fargate" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["events.amazonaws.com", "ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "hevc_fargate" {
  name               = "hevc-fargate"
  assume_role_policy = data.aws_iam_policy_document.assume_hevc_fargate.json
}

data "aws_iam_policy" "ecs" {
  name = "AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_role_policy_attachment" "hevc_fargate" {
  policy_arn = data.aws_iam_policy.ecs.arn
  role       = aws_iam_role.hevc_fargate.name
}

data "aws_iam_policy_document" "hevc_fargate" {
  statement {
    actions = [
      "s3:ListBucket*",
    ]
    resources = [
      aws_s3_bucket.hevc.arn,
    ]
  }
  statement {
    actions = [
      "s3:GetObject*",
    ]
    resources = [
      "${aws_s3_bucket.hevc.arn}/*",
    ]
  }
}

resource "aws_iam_role_policy" "hevc_fargate" {
  role   = aws_iam_role.hevc_fargate.name
  policy = data.aws_iam_policy_document.hevc_fargate.json
}
