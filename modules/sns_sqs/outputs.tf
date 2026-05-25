output "topic_arn" { 
    value = aws_sns_topic.notifications.arn 
}

output "queue_url" { 
    value = aws_sqs_queue.notifications.url 
}
