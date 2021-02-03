resource "aws_s3_bucket" "deploy" {
  bucket = "${local.appid}-serverless-deploy"
  acl    = "private"
}
