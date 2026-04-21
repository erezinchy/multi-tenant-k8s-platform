provider "aws" {
  region  = "eu-west-2"
  profile = "personal"
}

# 1. The State Bucket
resource "aws_s3_bucket" "terraform_state" {
  bucket = "terraform-state-storage-erez" # Generic name

  lifecycle {
    prevent_destroy = true
  }
}

# 2. Enable Versioning (Crucial for state recovery)
resource "aws_s3_bucket_versioning" "enabled" {
  bucket = aws_s3_bucket.terraform_state.id
  versioning_configuration {
    status = "Enabled"
  }
}

# 3. Encrypt at Rest (Senior Security Standard)
resource "aws_s3_bucket_server_side_encryption_configuration" "default" {
  bucket = aws_s3_bucket.terraform_state.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# 4. Block Public Access (Ensures 403 safety and security)
resource "aws_s3_bucket_public_access_block" "public_access" {
  bucket                  = aws_s3_bucket.terraform_state.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}