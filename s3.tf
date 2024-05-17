# The S3 bucket where the published file(s) will be stored.
resource "aws_s3_bucket" "egress_info" {
  provider = aws.deploy

  bucket = var.bucket_name
}

# Set a public read-only ACL on the bucket.
resource "aws_s3_bucket_acl" "egress_info" {
  provider = aws.deploy

  acl    = "public-read"
  bucket = aws_s3_bucket.egress_info.id

  depends_on = [
    aws_s3_bucket_ownership_controls.egress_info,
    aws_s3_bucket_public_access_block.egress_info,
  ]
}

# Policy that allows read-only access to the bucket.
data "aws_iam_policy_document" "egress_info" {
  policy_id = "egress_info_s3_bucket"

  statement {
    actions = [
      "s3:GetObject"
    ]
    effect = "Allow"
    principals {
      type        = "*"
      identifiers = ["*"]
    }
    resources = [
      "${aws_s3_bucket.egress_info.arn}/*"
    ]
    sid = "BucketPublicAccess"
  }
}

# Any objects placed into this bucket should be owned by the bucket
# owner. This ensures that even if objects are added by a different
# account, the bucket-owning account retains full control over the
# objects stored in this bucket.
resource "aws_s3_bucket_ownership_controls" "egress_info" {
  provider = aws.deploy

  bucket = aws_s3_bucket.egress_info.id

  rule {
    object_ownership = "BucketOwnerPreferred"
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

# Enable public access to this bucket so that the CloudFront distribution can
# serve the files stored in this bucket.
resource "aws_s3_bucket_public_access_block" "egress_info" {
  provider = aws.deploy

  bucket = aws_s3_bucket.egress_info.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
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
