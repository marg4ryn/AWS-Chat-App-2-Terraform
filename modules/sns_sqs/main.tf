resource "aws_sns_topic" "notifications" {
  name = "${var.app_name}-notifications"
}

resource "aws_sqs_queue" "notifications" {
  name                       = "${var.app_name}-notifications"
  visibility_timeout_seconds = 60
  message_retention_seconds  = 86400
}
