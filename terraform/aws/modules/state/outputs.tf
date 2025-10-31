output "s3_bucket_name" {
  description = "Name of the S3 bucket for remote state."
  value       = aws_s3_bucket.this.id
}
