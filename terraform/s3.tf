resource "aws_s3_bucket" "hevc" {
  bucket = "mdekort.hevc"
}

resource "aws_s3_bucket_lifecycle_configuration" "hevc" {
  bucket = aws_s3_bucket.hevc.id

  rule {
    id = "delete-old-files"

    filter {}

    expiration {
      days = 30
    }

    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "hevc" {
  bucket = aws_s3_bucket.hevc.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "aws:kms"
    }
  }
}


resource "aws_s3_bucket_ownership_controls" "hevc" {
  bucket = aws_s3_bucket.hevc.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_acl" "hevc" {
  depends_on = [aws_s3_bucket_ownership_controls.hevc]

  bucket = aws_s3_bucket.hevc.id
  acl    = "private"
}