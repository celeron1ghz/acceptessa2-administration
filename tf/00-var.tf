locals {
  appid = "acceptessa2"
  # login_endpoint = "xxxxxxxx.execute-api.ap-northeast-1.amazonaws.com"
  # apex_domain = "example.com"
}

provider "aws" {
  region = "ap-northeast-1"
}

provider "aws" {
  alias  = "virginia"
  region = "us-east-1"
}

# terraform {
#   required_version = ">= 0.14.0"

#   backend "s3" {
#     bucket = "xxxxxx"
#     key    = "xxxxxx.tfstate"
#     region = "ap-northeast-1"
#   }
# }
