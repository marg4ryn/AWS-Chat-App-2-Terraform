resource "aws_s3_bucket" "frontend" {
  bucket        = "${var.app_name}-frontend-272648"
  force_destroy = true
}

resource "aws_s3_bucket_website_configuration" "frontend" {
  bucket = aws_s3_bucket.frontend.id
  index_document { suffix = "index.html" }
  error_document { key = "index.html" }
}
