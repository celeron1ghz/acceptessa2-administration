locals {
  administrator_domain = "administration.${local.apex_domain}"
}


data "aws_acm_certificate" "domain" {
  domain   = "*.${local.apex_domain}"
  provider = aws.virginia
}

data "aws_route53_zone" "domain" {
  name = local.apex_domain
}


resource "aws_cloudfront_distribution" "dist" {
  enabled             = true
  is_ipv6_enabled     = true
  comment             = local.administrator_domain
  default_root_object = "index.html"
  aliases             = [local.administrator_domain]

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

  origin {
    origin_id   = "login"
    domain_name = local.login_endpoint

    custom_origin_config {
      http_port                = 443
      https_port               = 443
      origin_keepalive_timeout = 5
      origin_protocol_policy   = "https-only"
      origin_read_timeout      = 30
      origin_ssl_protocols     = ["TLSv1", "TLSv1.1", "TLSv1.2"]
    }
  }

  ordered_cache_behavior {
    path_pattern           = "/member/*"
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]
    target_origin_id       = "member"
    min_ttl                = 864000
    default_ttl            = 864000
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

  ordered_cache_behavior {
    path_pattern           = "/login"
    allowed_methods        = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods         = ["GET", "HEAD"]
    target_origin_id       = "login"
    min_ttl                = 0
    default_ttl            = 0
    max_ttl                = 0
    compress               = true
    viewer_protocol_policy = "redirect-to-https"

    forwarded_values {
      query_string = true
      headers      = ["Origin"]
      cookies {
        forward = "all"
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
    response_code      = "403"
    response_page_path = "/403.html"
  }

  custom_error_response {
    error_code         = "404"
    response_code      = "404"
    response_page_path = "/404.html"
  }
}

resource "aws_cloudfront_public_key" "key" {
  name        = "${local.appid}-administration"
  comment     = local.administrator_domain
  encoded_key = file("../privatekey/public_key.pem")
}

resource "aws_route53_record" "record" {
  type    = "A"
  name    = local.administrator_domain
  zone_id = data.aws_route53_zone.domain.id

  alias {
    name                   = aws_cloudfront_distribution.dist.domain_name
    zone_id                = "Z2FDTNDATAQYW2"
    evaluate_target_health = false
  }
}
