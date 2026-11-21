resource "random_id" "s3_suffix" {
  byte_length = 4
}

resource "aws_s3_bucket" "s3_kb_docs" {
  bucket = "bucket-knowledge-base-docs-${random_id.s3_suffix.hex}"

  tags = {
    ManagedBy   = "terraform"
    Environment = var.environment
  }
}