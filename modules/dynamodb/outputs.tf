output "notifications_table" { 
    value = aws_dynamodb_table.notifications.name 
}

output "subscriptions_table" { 
    value = aws_dynamodb_table.subscriptions.name 
}
