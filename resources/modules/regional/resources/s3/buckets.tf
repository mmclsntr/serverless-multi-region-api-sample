resource "aws_s3_bucket" "bucket" {
  bucket = "clp-mspdev-yamasaki-test-${var.stage}-${var.region}"
  acl    = "private"

  versioning {
    enabled = true
  }
}

output "s3_bucket_bucket_name" {
  value = aws_s3_bucket.bucket.bucket
}
