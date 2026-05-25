output "dns_name" { 
    value = aws_lb.main.dns_name 
}

output "auth_target_group_arn" { 
    value = aws_lb_target_group.auth.arn 
}

output "chat_target_group_arn" { 
    value = aws_lb_target_group.chat.arn 
}

output "media_target_group_arn" { 
    value = aws_lb_target_group.media.arn 
}

output "notifications_target_group_arn" { 
    value = aws_lb_target_group.notifications.arn 
}
