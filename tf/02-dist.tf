locals {
  domain = "administration.familiar-life.info"
}

data "aws_acm_certificate" "domain" {
  domain   = "*.familiar-life.info"
  provider = aws.virginia
}

data "aws_route53_zone" "domain" {
  name = "familiar-life.info"
}

resource "aws_cloudfront_distribution" "dist" {
  enabled             = true
  is_ipv6_enabled     = true
  comment             = local.domain
  default_root_object = "index.html"
  aliases             = [local.domain]

  origin {
    origin_id   = "root"
    domain_name = aws_s3_bucket.root.bucket_domain_name

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.root.cloudfront_access_identity_path
    }
  }

  origin {
    origin_id   = "member"
    domain_name = aws_s3_bucket.member.bucket_domain_name

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.member.cloudfront_access_identity_path
    }
  }

  ordered_cache_behavior {
    path_pattern           = "/member/*"
    allowed_methods        = ["GET", "HEAD", "OPTIONS"]
    cached_methods         = ["GET", "HEAD", "OPTIONS"]
    target_origin_id       = "member"
    min_ttl                = 864000
    default_ttl            = 864000
    max_ttl                = 864000
    compress               = true
    viewer_protocol_policy = "redirect-to-https"

    forwarded_values {
      query_string = false
      headers      = ["Origin"]
      cookies {
        forward = "none"
      }
    }
  }

  default_cache_behavior {
    target_origin_id       = "root"
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]
    default_ttl            = 864000
    min_ttl                = 864000
    max_ttl                = 864000
    compress               = true
    viewer_protocol_policy = "redirect-to-https"

    forwarded_values {
      query_string = true
      headers      = ["Origin"]
      cookies {
        forward = "none"
      }
    }
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    acm_certificate_arn = data.aws_acm_certificate.domain.arn
    ssl_support_method  = "sni-only"
  }

  custom_error_response {
    error_code         = "403"
    response_code      = "200"
    response_page_path = "/index.html"
  }
}

resource "aws_cloudfront_public_key" "key" {
  name        = "acceptessa2-administration"
  comment     = local.domain
  encoded_key = file("public_key.pem")
}

resource "aws_route53_record" "record" {
  type    = "A"
  name    = local.domain
  zone_id = data.aws_route53_zone.domain.id

  alias {
    name                   = aws_cloudfront_distribution.dist.domain_name
    zone_id                = "Z2FDTNDATAQYW2"
    evaluate_target_health = false
  }
}
