# AWS DevOps Project 1 — GitHub → Jenkins → Docker → Terraform → AWS

This starter repo includes:
- Simple Node.js app (`/app`)
- Dockerfile to containerize it
- Terraform to provision an EC2 instance and run the container
- Jenkinsfile pipeline

## Quick start
1. Create a DockerHub repo and update `Jenkinsfile` IMAGE_NAME.
2. In Jenkins, add credentials:
   - `dockerhub-cred` (Username with password)
   - `aws-access-key-id` (Secret text)
   - `aws-secret-access-key` (Secret text)
3. Create an EC2 key pair in your AWS region and set `KEY_NAME` parameter when running the pipeline.
4. Run the pipeline. On success, Terraform outputs `app_url` to open in your browser.
