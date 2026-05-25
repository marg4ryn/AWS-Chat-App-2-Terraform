resource "aws_dynamodb_table" "notifications" {
  name         = "${var.app_name}-notifications"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "userId"
  range_key    = "createdAt"

  attribute {
    name = "userId"
    type = "S"
  }
  attribute {
    name = "createdAt"
    type = "S"
  }
}

resource "aws_dynamodb_table" "subscriptions" {
  name         = "${var.app_name}-subscriptions"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "userId"
  range_key    = "roomId"

  attribute {
    name = "userId"
    type = "S"
  }
  attribute {
    name = "roomId"
    type = "S"
  }
}
