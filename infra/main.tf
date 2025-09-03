provider "aws" {
  region = var.aws_region
}

data "aws_vpc" "default" {
  default = true
}

data "aws_ami" "al2" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

resource "aws_security_group" "app_sg" {
  name        = "devops-app-sg"
  description = "Allow HTTP to app"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.allowed_cidr
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = var.allowed_cidr
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "devops-app-sg"
  }
}
resource "aws_instance" "app_server" {
  ami                    = data.aws_ami.al2.id
  instance_type          = var.instance_type
  vpc_security_group_ids = [aws_security_group.app_sg.id]
  key_name               = var.key_name

  depends_on = [aws_security_group.app_sg]

  user_data = <<-EOF
    #!/bin/bash
sudo yum update -y
sudo amazon-linux-extras install docker -y
sudo service docker start
sudo usermod -aG docker ec2-user

# Always remove old container
docker rm -f devops-app || true

# Always pull the latest image
docker pull your_dockerhub_user/aws-devops-app:latest

# Run fresh container
docker run -d -p 80:3000 --name devops-app your_dockerhub_user/aws-devops-app:latest
EOF

  tags = {
    Name = "DevOps-App-Server"
  }
}

output "public_ip" {
  value = aws_instance.app_server.public_ip
}

output "app_url" {
  value = "http://${aws_instance.app_server.public_ip}"
}
