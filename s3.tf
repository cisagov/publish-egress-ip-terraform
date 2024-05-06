# The S3 bucket where the published file(s) will be stored.

resource "aws_s3_bucket" "egress_info" {
  provider = aws.deploy

  bucket = var.bucket_name
}

resource "aws_s3_bucket_acl" "egress_info" {
  provider = aws.deploy

  bucket = aws_s3_bucket.egress_info.id
  acl    = "private"
}

resource "aws_s3_bucket_server_side_encryption_configuration" "egress_info" {
  provider = aws.deploy

  bucket = aws_s3_bucket.egress_info.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}
