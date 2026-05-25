output "client_id" {
  value = aws_cognito_user_pool_client.main.id
}

output "client_secret" {
  value     = aws_cognito_user_pool_client.main.client_secret
  sensitive = true
}

output "issuer_uri" { 
  value = "https://cognito-idp.${var.aws_region}.amazonaws.com/${aws_cognito_user_pool.main.id}" 
}
