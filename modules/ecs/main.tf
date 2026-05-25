data "aws_caller_identity" "current" {}

resource "aws_ecs_cluster" "main" {
  name = "${var.app_name}-cluster"
}
