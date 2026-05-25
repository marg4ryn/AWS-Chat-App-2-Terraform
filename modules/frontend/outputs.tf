output "bucket_name" { 
    value = aws_s3_bucket.frontend.bucket 
}

output "frontend_url" { 
    value = aws_s3_bucket_website_configuration.frontend.website_endpoint 
}
