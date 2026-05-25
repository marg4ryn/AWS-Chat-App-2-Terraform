output "cluster_id" { 
    value = aws_ecs_cluster.main.id 
}

output "cluster_name" {
     value = aws_ecs_cluster.main.name
}

output "task_execution_role_arn" { 
    value = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/LabRole" 
}

output "task_role_arn" { 
    value = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/LabRole"
}
