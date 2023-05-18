variable "aws_region" {
  description = "AWS regoin"
  type        = string
  default     = "us-east-1"
}

variable "bucket_name" {
  description = "S3 bucket name"
  type        = string
  default     = "super-defualt-name-"

  validation {
    condition     = length(var.bucket_name) > 2 && length(var.bucket_name) < 64 && can(regex("^[0-9A-Za-z-]+$", var.bucket_name))
    error_message = "figure it out"
  }
}

variable "access_logging_bucket_name" {
  description = "S3 access logging"
  type        = string
  default     = "my-access-logging-bucket-name"
}

locals {
  bucket_count = 100
  bucket_names = [for i in range(local.bucket_count) : "${var.bucket_name}${i + 1}"]
}
