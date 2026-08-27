variable "aws_region" {
  default     = "us-east-1"
  description = "The AWS region to deploy the infrastructure"
}

variable "vpc_cidr" {
  default     = "10.0.0.0/16"
  description = "CIDR block for the main VPC"
}