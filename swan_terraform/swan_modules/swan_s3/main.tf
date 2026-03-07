# S3 Bucket
resource "aws_s3_bucket" "swan_s3_bucket" {
  bucket        = var.swan_s3_bucket_name
  force_destroy = true
}

# Block all public access
resource "aws_s3_bucket_public_access_block" "swan_s3_bucket_public_access_block" {
  bucket       = aws_s3_bucket.swan_s3_bucket.id
  skip_destroy = true

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Enable Bucket Versioning
resource "aws_s3_bucket_versioning" "swan_s3_bucket_versioning" {
  bucket = aws_s3_bucket.swan_s3_bucket.id

  versioning_configuration {
    status = "Enabled"
  }
}

# Enable SSE-S3 encryption type (Default encryption)
resource "aws_s3_bucket_server_side_encryption_configuration" "swan_s3_bucket_server_side_encryption_configuration" {
  bucket = aws_s3_bucket.swan_s3_bucket.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# S3 Bucket Policy
resource "aws_s3_bucket_policy" "swan_s3_bucket_policy" {
  bucket = aws_s3_bucket.swan_s3_bucket.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "DenyInsecureTransport"
        Effect    = "Deny"
        Principal = "*"
        Action    = "s3:*"
        Resource = [
          aws_s3_bucket.swan_s3_bucket.arn,
          "${aws_s3_bucket.swan_s3_bucket.arn}/*"
        ]
        Condition = {
          Bool = {
            "aws:SecureTransport" = "false"
          }
        }
      }
    ]
  })
}