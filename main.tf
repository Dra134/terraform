terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0.0"
    }
  }

  required_version = ">= 0.15"
}

provider "aws" {
  profile = "default"
  region  = var.aws_region
}

# Managed KMS Key

resource "aws_kms_key" "kms_s3_key" {
  description             = "Key to protect S3 objects"
  key_usage               = "ENCRYPT_DECRYPT"
  deletion_window_in_days = 7
  is_enabled              = true
}

resource "aws_kms_alias" "kms_s3_key_alias" {
  name          = "alias/s3-key"
  target_key_id = aws_kms_key.kms_s3_key.key_id

}

# Bucket Creation

resource "aws_s3_bucket" "my_bucket" {
  for_each = toset(local.bucket_names)

  bucket = each.key
}

# Bucket ACL

resource "aws_s3_bucket_acl" "my_bucket_acl" {
  for_each = aws_s3_bucket.my_bucket

  bucket = each.value.id
  acl    = "private"
}

# Server Side Encryption

resource "aws_s3_bucket_server_side_encryption_configuration" "my_bucket_sse" {
  for_each = aws_s3_bucket.my_bucket

  bucket = each.value.bucket

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.kms_s3_key.arn
      sse_algorithm     = "aws:kms"
    }
  }
}

# Disable Public Access

resource "aws_s3_bucket_public_access_block" "my_bucket_access" {
  for_each = aws_s3_bucket.my_bucket

  bucket = each.value.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
