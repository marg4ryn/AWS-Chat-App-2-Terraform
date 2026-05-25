resource "aws_s3_bucket" "media" {
  bucket        = "${var.app_name}-media-272648"
  force_destroy = true

  tags = {
    Name = "${var.app_name}-media-272648"
  }
}
