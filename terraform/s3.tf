resource "aws_s3_bucket" "hevc" {
  bucket = "mdekort.hevc"
}

resource "aws_s3_bucket_lifecycle_configuration" "hevc" {
  bucket = aws_s3_bucket.hevc.id

  rule {
    id     = "delete-todo-files"
    status = "Enabled"

    filter { prefix = "TODO/" }
    expiration { days = 1 }
  }

  rule {
    id     = "delete-done-files"
    status = "Enabled"

    filter { prefix = "DONE/" }
    expiration { days = 3 }
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

resource "aws_s3_bucket_notification" "hevc" {
  bucket      = aws_s3_bucket.hevc.id
  eventbridge = true
}
