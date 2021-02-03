locals {
  name = "${local.appid}-administration"
}

data "aws_region" "current" {}

data "aws_caller_identity" "current" {}

data "aws_iam_policy_document" "assume-administration" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "policy-administration" {
  statement {
    sid     = "1"
    actions = ["logs:CreateLogStream"]
    resources = [
      "arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:log-group:/aws/lambda/${local.name}:*"
    ]
  }

  statement {
    sid     = "2"
    actions = ["logs:PutLogEvents"]
    resources = [
      "arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:log-group:/aws/lambda/${local.name}:*:*"
    ]
  }
}

resource "aws_ecr_repository" "administration" {
  name                 = "${local.appid}-administration"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "aws_ecr_lifecycle_policy" "policy" {
  repository = aws_ecr_repository.administration.name

  policy = <<EOF
{
    "rules": [
        {
            "rulePriority": 1,
            "description": "Keep last 3 images",
            "selection": {
                "tagStatus": "any",
                "countType": "imageCountMoreThan",
                "countNumber": 3
            },
            "action": {
                "type": "expire"
            }
        }
    ]
}
EOF
}

resource "aws_iam_role" "administration" {
  name               = "${local.appid}-administration"
  assume_role_policy = data.aws_iam_policy_document.assume-administration.json
}

resource "aws_iam_policy" "administration" {
  name   = "${local.appid}-administration"
  policy = data.aws_iam_policy_document.policy-administration.json
}

resource "aws_iam_role_policy_attachment" "attach-administration" {
  role       = aws_iam_role.administration.name
  policy_arn = aws_iam_policy.administration.arn
}

resource "aws_cloudwatch_log_group" "sender" {
  name              = "/aws/lambda/${local.name}"
  retention_in_days = 14
}

resource "aws_lambda_function" "administration" {
  function_name = local.name
  description   = "${local.appid} administration api"
  package_type  = "Image"
  image_uri     = "${aws_ecr_repository.administration.repository_url}:latest"
  role          = aws_iam_role.administration.arn
  timeout       = 60
  memory_size   = 1024

  lifecycle {
    ignore_changes = [image_uri]
  }
  environment {
    variables = {
      "PAWS_SILENCE_UNSTABLE_WARNINGS" = "1"
    }
  }
}
