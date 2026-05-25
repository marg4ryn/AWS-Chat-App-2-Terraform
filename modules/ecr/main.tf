resource "aws_ecr_repository" "services" {
  for_each      = toset(var.services)
  name          = "${var.app_name}-${each.key}"
  force_delete  = true

  image_scanning_configuration {
    scan_on_push = true
  }
}
