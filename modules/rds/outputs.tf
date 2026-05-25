output "endpoint" { 
    value = aws_db_instance.main.endpoint 
}

output "db_name" { 
    value = var.db_name 
}
