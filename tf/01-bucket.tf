resource "aws_s3_bucket" "root" {
  bucket = "${local.appid}-administration-root"
}

resource "aws_s3_bucket" "member" {
  bucket = "${local.appid}-administration-member"
}


resource "aws_cloudfront_origin_access_identity" "root" {
  comment = "${local.appid}-administration-root"
}

resource "aws_cloudfront_origin_access_identity" "member" {
  comment = "${local.appid}-administration-member"
}


resource "aws_s3_bucket_policy" "root" {
  bucket = aws_s3_bucket.root.id
  policy = data.aws_iam_policy_document.root.json
}

resource "aws_s3_bucket_policy" "member" {
  bucket = aws_s3_bucket.member.id
  policy = data.aws_iam_policy_document.member.json
}


data "aws_iam_policy_document" "root" {
  statement {
    sid       = "1"
    effect    = "Allow"
    actions   = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.root.arn}/*"]
    principals {
      type        = "AWS"
      identifiers = [aws_cloudfront_origin_access_identity.root.iam_arn]
    }
  }
}

data "aws_iam_policy_document" "member" {
  statement {
    sid       = "1"
    effect    = "Allow"
    actions   = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.member.arn}/*"]
    principals {
      type        = "AWS"
      identifiers = [aws_cloudfront_origin_access_identity.member.iam_arn]
    }
  }
}


