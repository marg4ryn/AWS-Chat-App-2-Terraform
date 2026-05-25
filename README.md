# Deployment Guide

## 1. Preparation

```powershell
aws configure  # configure AWS Academy credentials
terraform init
````

---

## 2. Terraform Infrastructure

```powershell
cd terraform

terraform plan
terraform apply
```

After `terraform apply`, save the outputs:

```powershell
terraform output  # save api_url, frontend_url and ecrs_ids
```

---

## 3. Build and Push Docker Images

### Authenticate Docker with ECR

```powershell
$password = aws ecr get-login-password --region <region>

docker login `
  --username AWS `
  --password $password `
  <account-id>.dkr.ecr.<region>.amazonaws.com
```

---

### Auth Service

```powershell
cd auth-service

docker build -t app-auth .

docker tag app-auth:latest `
  <account-id>.dkr.ecr.<region>.amazonaws.com/app-auth:latest

docker push `
  <account-id>.dkr.ecr.<region>.amazonaws.com/app-auth:latest
```

---

### Chat Service

```powershell
cd ../chat-service

docker build -t app-chat .

docker tag app-chat:latest `
  <account-id>.dkr.ecr.<region>.amazonaws.com/app-chat:latest

docker push `
  <account-id>.dkr.ecr.<region>.amazonaws.com/app-chat:latest
```

---

### Media Service

```powershell
cd ../media-service

docker build -t app-media .

docker tag app-media:latest `
  <account-id>.dkr.ecr.<region>.amazonaws.com/app-media:latest

docker push `
  <account-id>.dkr.ecr.<region>.amazonaws.com/app-media:latest
```

---

### Notifications Service

```powershell
cd ../notifications-service

docker build -t app-notifications .

docker tag app-notifications:latest `
  <account-id>.dkr.ecr.<region>.amazonaws.com/app-notifications:latest

docker push `
  <account-id>.dkr.ecr.<region>.amazonaws.com/app-notifications:latest
```

---

## 4. ECS Deployment

Restarting ECS services is not required during the first deployment.
Use forced deployments only when updating Docker images.

```powershell
aws ecs update-service `
  --cluster app-cluster `
  --service app-auth `
  --force-new-deployment

aws ecs update-service `
  --cluster app-cluster `
  --service app-chat `
  --force-new-deployment

aws ecs update-service `
  --cluster app-cluster `
  --service app-media `
  --force-new-deployment

aws ecs update-service `
  --cluster app-cluster `
  --service app-notifications `
  --force-new-deployment
```

---

## 5. Frontend Build and Deployment

Open the AWS S3 Console, locate the frontend bucket, disable **Block Public Access**, and add a bucket policy.
This step is required only during the first deployment.

### Example Bucket Policy

```json
{
  "Version": "2012-10-17",
  "Statement": [{
    "Effect": "Allow",
    "Principal": "*",
    "Action": "s3:GetObject",
    "Resource": "arn:aws:s3:::<frontend-bucket-name>/*"
  }]
}
```

---

### Build and Upload Frontend Files

```powershell
cd frontend

$albUrl = "http://<application-load-balancer-url>"

$config = "window.APP_CONFIG = { apiUrl: `"$albUrl`" };"

Set-Content `
  -Path "public/config.js" `
  -Value $config

npm install
npm run build

aws s3 sync dist/ s3://<frontend-bucket-name> --delete
```

---

## 6. Verification

### Check ECS Tasks

```powershell
aws ecs list-tasks `
  --cluster app-cluster `
  --service-name app-auth

aws ecs list-tasks `
  --cluster app-cluster `
  --service-name app-chat

aws ecs list-tasks `
  --cluster app-cluster `
  --service-name app-media

aws ecs list-tasks `
  --cluster app-cluster `
  --service-name app-notifications
```

---

### View CloudWatch Logs

```powershell
aws logs tail /ecs/app/auth --follow

aws logs tail /ecs/app/chat --follow

aws logs tail /ecs/app/media --follow

aws logs tail /ecs/app/notifications --follow
```

---

## Application URL

```powershell
terraform output -raw frontend_url
```

Example:

```text
http://<frontend-bucket-name>.s3-website-<region>.amazonaws.com
```
