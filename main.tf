terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

module "ecs" {
  source   = "./modules/ecs"
  app_name = var.app_name
}

module "networking" {
  source   = "./modules/networking"
  app_name = var.app_name
}

module "cognito" {
  source     = "./modules/cognito"
  app_name   = var.app_name
  aws_region = var.aws_region
}

module "ecr" {
  source   = "./modules/ecr"
  app_name = var.app_name
  services = ["auth", "chat", "media", "notifications"]
}

module "alb" {
  source            = "./modules/alb"
  app_name          = var.app_name
  vpc_id            = module.networking.vpc_id
  public_subnet_ids = module.networking.public_subnet_ids
  alb_sg_id         = module.networking.alb_sg_id
}

module "rds_chat" {
  source      = "./modules/rds"
  app_name    = var.app_name
  db_name     = "chatdb"
  db_username = var.db_username
  db_password = var.db_password
  subnet_ids  = module.networking.private_subnet_ids
  sg_id       = module.networking.rds_sg_id
}

module "rds_media" {
  source      = "./modules/rds"
  app_name    = var.app_name
  db_name     = "mediadb"
  db_username = var.db_username
  db_password = var.db_password
  subnet_ids  = module.networking.private_subnet_ids
  sg_id       = module.networking.rds_sg_id
}

module "dynamodb" {
  source   = "./modules/dynamodb"
  app_name = var.app_name
}

module "s3_media" {
  source            = "./modules/s3"
  app_name          = var.app_name
}

module "sns_sqs" {
  source   = "./modules/sns_sqs"
  app_name = var.app_name
}

module "chat_service" {
  source                  = "./modules/fargate_service"
  app_name                = var.app_name
  service_name            = "chat"
  cluster_id              = module.ecs.cluster_id
  cluster_name            = module.ecs.cluster_name
  task_execution_role_arn = module.ecs.task_execution_role_arn
  task_role_arn           = module.ecs.task_role_arn
  image_url               = "${module.ecr.repository_urls["chat"]}:latest"
  container_port          = 8080
  subnet_ids              = module.networking.private_subnet_ids
  security_group_ids      = [module.networking.ecs_sg_id]
  target_group_arn        = module.alb.chat_target_group_arn
  aws_region              = var.aws_region
  environment_variables = [
    { name = "AWS_REGION",                 value = var.aws_region },
    { name = "COGNITO_ISSUER_URI",         value = module.cognito.issuer_uri },
    { name = "MEDIA_SERVICE_URL",          value = "http://${module.alb.dns_name}" },
    { name = "SQS_QUEUE_URL",              value = module.sns_sqs.queue_url },
    { name = "SPRING_DATASOURCE_URL",      value = "jdbc:postgresql://${module.rds_chat.endpoint}/${module.rds_chat.db_name}" },
    { name = "SPRING_DATASOURCE_USERNAME", value = var.db_username },
    { name = "SPRING_DATASOURCE_PASSWORD", value = var.db_password },
    { name = "SERVER_PORT",                value = "8080" },
  ]
}

module "media_service" {
  source                  = "./modules/fargate_service"
  app_name                = var.app_name
  service_name            = "media"
  cluster_id              = module.ecs.cluster_id
  cluster_name            = module.ecs.cluster_name
  task_execution_role_arn = module.ecs.task_execution_role_arn
  task_role_arn           = module.ecs.task_role_arn
  image_url               = "${module.ecr.repository_urls["media"]}:latest"
  container_port          = 8081
  subnet_ids              = module.networking.private_subnet_ids
  security_group_ids      = [module.networking.ecs_sg_id]
  target_group_arn        = module.alb.media_target_group_arn
  aws_region              = var.aws_region
  environment_variables = [
    { name = "AWS_REGION",                 value = var.aws_region },
    { name = "COGNITO_ISSUER_URI",         value = module.cognito.issuer_uri },
    { name = "S3_BUCKET",                  value = module.s3_media.bucket_name },
    { name = "S3_REGION",                  value = var.aws_region },
    { name = "SPRING_DATASOURCE_URL",      value = "jdbc:postgresql://${module.rds_media.endpoint}/${module.rds_media.db_name}" },
    { name = "SPRING_DATASOURCE_USERNAME", value = var.db_username },
    { name = "SPRING_DATASOURCE_PASSWORD", value = var.db_password },
    { name = "SERVER_PORT",                value = "8081" },
  ]
}

module "notifications_service" {
  source                  = "./modules/fargate_service"
  app_name                = var.app_name
  service_name            = "notifications"
  cluster_id              = module.ecs.cluster_id
  cluster_name            = module.ecs.cluster_name
  task_execution_role_arn = module.ecs.task_execution_role_arn
  task_role_arn           = module.ecs.task_role_arn
  image_url               = "${module.ecr.repository_urls["notifications"]}:latest"
  container_port          = 8082
  subnet_ids              = module.networking.private_subnet_ids
  security_group_ids      = [module.networking.ecs_sg_id]
  target_group_arn        = module.alb.notifications_target_group_arn
  aws_region              = var.aws_region
  environment_variables = [
    { name = "AWS_REGION",                   value = var.aws_region },
    { name = "COGNITO_ISSUER_URI",           value = module.cognito.issuer_uri },
    { name = "SNS_TOPIC_ARN",                value = module.sns_sqs.topic_arn },
    { name = "SQS_QUEUE_NAME",               value = module.sns_sqs.queue_url },
    { name = "DYNAMODB_NOTIFICATIONS_TABLE", value = module.dynamodb.notifications_table },
    { name = "DYNAMODB_SUBSCRIPTIONS_TABLE", value = module.dynamodb.subscriptions_table },
    { name = "SERVER_PORT",                  value = "8082" },
  ]
}

module "auth_service" {
  source                  = "./modules/fargate_service"
  app_name                = var.app_name
  service_name            = "auth"
  cluster_id              = module.ecs.cluster_id
  cluster_name            = module.ecs.cluster_name
  task_execution_role_arn = module.ecs.task_execution_role_arn
  task_role_arn           = module.ecs.task_role_arn
  image_url               = "${module.ecr.repository_urls["auth"]}:latest"
  container_port          = 8083
  subnet_ids              = module.networking.private_subnet_ids
  security_group_ids      = [module.networking.ecs_sg_id]
  target_group_arn        = module.alb.auth_target_group_arn
  aws_region              = var.aws_region
  environment_variables = [
    { name = "AWS_REGION",            value = var.aws_region },
    { name = "COGNITO_CLIENT_ID",     value = module.cognito.client_id },
    { name = "COGNITO_CLIENT_SECRET", value = module.cognito.client_secret },
    { name = "SERVER_PORT",           value = "8083" },
  ]
}

module "frontend" {
  source   = "./modules/frontend"
  app_name = var.app_name
}
