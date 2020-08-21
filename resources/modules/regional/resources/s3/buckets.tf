data "aws_caller_identity" "current" {}

output "account_id" {
  value = data.aws_caller_identity.current.account_id
}
resource "aws_s3_bucket" "bucket" {
  bucket = "${var.api_name}-${data.aws_caller_identity.current.account_id}-${var.stage}-${var.region}"
  acl    = "private"

  versioning {
    enabled = true
  }
}

output "s3_bucket_bucket_name" {
  value = aws_s3_bucket.bucket.bucket
}
