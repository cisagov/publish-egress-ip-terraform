output "bucket" {
  value       = aws_s3_bucket.egress_info
  description = "The S3 bucket where egress IP address information is published."
}
