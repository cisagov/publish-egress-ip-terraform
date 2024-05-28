# The S3 bucket where the published file(s) will be stored.
resource "aws_s3_bucket" "egress_info" {
  provider = aws.deploy

  bucket = var.bucket_name
}


# Policy that only allows the CloudFront distribution to read from the bucket.
data "aws_iam_policy_document" "egress_info" {
  policy_id = "egress_info_s3_bucket"

  statement {
    actions = [
      "s3:GetObject"
    ]

    condition {
      test     = "StringEquals"
      variable = "AWS:SourceArn"

      values = [
        aws_cloudfront_distribution.egress_info.arn
      ]
    }

    principals {
      identifiers = ["cloudfront.amazonaws.com"]
      type        = "Service"
    }

    resources = [
      "${aws_s3_bucket.egress_info.arn}/*"
    ]
  }

  statement {
    actions = ["s3:ListBucket"]

    condition {
      test     = "StringEquals"
      variable = "AWS:SourceArn"

      values = [
        aws_cloudfront_distribution.egress_info.arn
      ]
    }

    principals {
      identifiers = ["cloudfront.amazonaws.com"]
      type        = "Service"
    }

    resources = [aws_s3_bucket.egress_info.arn]
  }
}

# Any objects placed into this bucket should be owned by the bucket owner. This
# ensures that even if objects are added by a different account, the
# bucket-owning account retains full control over the objects stored in this
# bucket.
resource "aws_s3_bucket_ownership_controls" "egress_info" {
  provider = aws.deploy

  bucket = aws_s3_bucket.egress_info.id

  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

# Apply our read-only policy to the bucket.
resource "aws_s3_bucket_policy" "egress_info" {
  provider = aws.deploy

  bucket = aws_s3_bucket.egress_info.id
  policy = data.aws_iam_policy_document.egress_info.json

  depends_on = [
    aws_s3_bucket_public_access_block.egress_info,
  ]
}

# This blocks ANY public access to the bucket or the objects it contains, even
# if misconfigured to allow public access.
resource "aws_s3_bucket_public_access_block" "egress_info" {
  provider = aws.deploy

  block_public_acls       = true
  block_public_policy     = true
  bucket                  = aws_s3_bucket.egress_info.id
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Set the default server-side encryption for the bucket to AES256.
resource "aws_s3_bucket_server_side_encryption_configuration" "egress_info" {
  provider = aws.deploy

  bucket = aws_s3_bucket.egress_info.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}
