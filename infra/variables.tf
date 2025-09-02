variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "ap-south-1"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

variable "key_name" {
  description = "Existing EC2 key pair name to allow SSH"
  type        = string
}

variable "allowed_cidr" {
  description = "CIDR allowed to access HTTP (80)"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "docker_image" {
  description = "baskarb/myapp:latest)"
  type        = string
}
