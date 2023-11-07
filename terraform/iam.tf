# Eventbridge -> Fargate role
data "aws_iam_policy_document" "assume_eventbridge_fargate" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["events.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "eventbridge_fargate" {
  name               = "eventbridge-fargate"
  path               = "/system/"
  assume_role_policy = data.aws_iam_policy_document.assume_eventbridge_fargate.json
}

data "aws_iam_policy_document" "eventbridge_fargate" {
  statement {
    actions = [
      "ecs:RunTask",
    ]
    resources = [
      "*",
    ]
  }
  statement {
    actions = [
      "iam:PassRole",
    ]
    resources = [
      aws_iam_role.hevc_fargate_execution.arn,
      aws_iam_role.hevc_fargate_task.arn,
    ]
  }
}

resource "aws_iam_role_policy" "eventbridge_fargate" {
  role   = aws_iam_role.eventbridge_fargate.name
  policy = data.aws_iam_policy_document.eventbridge_fargate.json
}

# Assume policy for both task and execution roles
data "aws_iam_policy_document" "assume_hevc_fargate" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

# Fargate execution role
resource "aws_iam_role" "hevc_fargate_execution" {
  name               = "hevc-fargate-execution"
  path               = "/system/"
  assume_role_policy = data.aws_iam_policy_document.assume_hevc_fargate.json
}

data "aws_iam_policy" "hevc_fargate_execution" {
  name = "AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_role_policy_attachment" "hevc_fargate_execution" {
  policy_arn = data.aws_iam_policy.hevc_fargate_execution.arn
  role       = aws_iam_role.hevc_fargate_execution.name
}

# Fargate task role
resource "aws_iam_role" "hevc_fargate_task" {
  name               = "hevc-fargate-task"
  path               = "/system/"
  assume_role_policy = data.aws_iam_policy_document.assume_hevc_fargate.json
}

data "aws_iam_policy_document" "hevc_fargate_task" {
  statement {
    actions = [
      "s3:GetBucket*",
      "s3:HeadBucket",
      "s3:ListBucket*",
    ]
    resources = [
      aws_s3_bucket.hevc.arn,
    ]
  }
  statement {
    actions = [
      "s3:DeleteObject*",
      "s3:GetObject*",
      "s3:HeadObject*",
      "s3:ListObject*",
      "s3:PutObject*",
    ]
    resources = [
      "${aws_s3_bucket.hevc.arn}/*",
    ]
  }
  statement {
    actions = [
      "events:PutEvents",
      "ecs:ListTasks",
      "ecs:DescribeTasks",
    ]
    resources = ["*"]
  }
}

resource "aws_iam_role_policy" "hevc_fargate_task" {
  role   = aws_iam_role.hevc_fargate_task.name
  policy = data.aws_iam_policy_document.hevc_fargate_task.json
}

# lmbackup user
data "aws_iam_policy_document" "lmbackup" {
  statement {
    actions = [
      "s3:Get*",
      "s3:List*",
      "s3:Put*",
    ]
    resources = [
      aws_s3_bucket.hevc.arn,
      "${aws_s3_bucket.hevc.arn}/*",
    ]
  }
}

resource "aws_iam_user_policy" "lmbackup" {
  user   = data.terraform_remote_state.cloudsetup.outputs.lmbackup_user
  policy = data.aws_iam_policy_document.lmbackup.json
}
