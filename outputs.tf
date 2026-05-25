output "alb_url" { 
    value = "http://${module.alb.dns_name}" 
}

output "frontend_url" {
  value = module.frontend.frontend_url
}

output "ecr_repositories" {
  value = module.ecr.repository_urls
}