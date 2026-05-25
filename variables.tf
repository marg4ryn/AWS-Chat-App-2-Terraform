variable "app_name" {
    type = string
    default = "chatapp"
}

variable "aws_region" {
    type = string
    default = "us-east-1"
}

variable "db_username" {
    type = string
    default = "chatappuser"
}

variable "db_password" {
    type = string
    sensitive = true
}
