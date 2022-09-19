# ------------------------------------------------------------------------------
# The CloudFront distribution and related S3/Lambda resources that allow us to
# use an HTTPS endpoint, which S3 websites do not support natively.
# ------------------------------------------------------------------------------

locals {
  # bucket origin id
  s3_origin_id = "S3-${aws_s3_bucket.egress_info.id}"
}

data "aws_acm_certificate" "rules_cert" {
  # This certificate must exist prior to applying this Terraform.
  # For an example, see cisagov/cool-dns-cyber.dhs.gov/acm_rules_vm.tf
  provider = aws.deploy

  domain      = var.domain
  most_recent = true
  statuses    = ["ISSUED"]
  types       = ["AMAZON_ISSUED"]
}

# An S3 bucket where artifacts for the Lambda@Edge can be stored
resource "aws_s3_bucket" "lambda_at_edge" {
  provider = aws.deploy

  bucket_prefix = "publish-egress-ip-lambda-at-edge-"

  # TODO: Remove this lifecycle block after we move to version 4.x of the
  # Terraform AWS provider.  For more info, see:
  # https://github.com/cisagov/publish-egress-ip-terraform/issues/5
  lifecycle {
    ignore_changes = [
      server_side_encryption_configuration
    ]
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "lambda_at_edge" {
  provider = aws.deploy

  bucket = aws_s3_bucket.lambda_at_edge.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_versioning" "lambda_at_edge" {
  provider = aws.deploy

  bucket = aws_s3_bucket.lambda_at_edge.id
  versioning_configuration {
    status = "Enabled"
  }
}

# This blocks ANY public access to the bucket or the objects it
# contains, even if misconfigured to allow public access.
resource "aws_s3_bucket_public_access_block" "lambda_artifact_bucket" {
  provider = aws.deploy

  bucket = aws_s3_bucket.lambda_at_edge.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# A Lambda@Edge for injecting security headers
module "security_header_lambda" {
  providers = {
    aws = aws.deploy
  }

  source  = "transcend-io/lambda-at-edge/aws"
  version = "0.5.0"

  description            = "Adds HSTS and other security headers to the response."
  lambda_code_source_dir = "${path.root}/add_security_headers"
  name                   = "add_security_headers"
  s3_artifact_bucket     = aws_s3_bucket.lambda_at_edge.id
}

resource "aws_cloudfront_distribution" "rules_s3_distribution" {
  provider = aws.deploy

  origin {
    domain_name = aws_s3_bucket.egress_info.bucket_regional_domain_name
    origin_id   = local.s3_origin_id
  }

  aliases             = [var.domain]
  comment             = "Created by cisagov/publish-egress-ip-terraform."
  default_root_object = var.root_object
  enabled             = true
  is_ipv6_enabled     = true

  default_cache_behavior {
    allowed_methods = ["GET", "HEAD"]
    cached_methods  = ["GET", "HEAD"]
    lambda_function_association {
      # Inject security headers via Lambda@Edge
      event_type   = "origin-response"
      include_body = false
      lambda_arn   = module.security_header_lambda.arn
    }
    target_origin_id = local.s3_origin_id

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }
    compress               = true
    default_ttl            = 30
    max_ttl                = 30
    min_ttl                = 0
    viewer_protocol_policy = "redirect-to-https"
  }

  price_class = "PriceClass_100"

  restrictions {
    geo_restriction {
      locations        = ["AS", "GU", "MP", "PR", "US", "VI"]
      restriction_type = "whitelist"
    }
  }

  custom_error_response {
    error_caching_min_ttl = 30
    error_code            = 403
    response_code         = 200
    response_page_path    = "/${var.root_object}"
  }

  custom_error_response {
    error_caching_min_ttl = 30
    error_code            = 404
    response_code         = 200
    response_page_path    = "/${var.root_object}"
  }

  viewer_certificate {
    acm_certificate_arn      = data.aws_acm_certificate.rules_cert.arn
    minimum_protocol_version = "TLSv1.1_2016"
    ssl_support_method       = "sni-only"
  }
}
