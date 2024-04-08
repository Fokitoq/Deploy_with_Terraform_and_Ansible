# variables.tf

variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "aws_ami" {
  description = "AMI ID"
  type        = string
  default     = "ami-0a699202e5027c10d"
}

variable "aws_instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t2.micro"
}

variable "aws_account_id" {
  description = "AWS account ID"
  type        = string
  default     = "690483157857"
}


variable "azs" {
 type        = list(string)
 description = "Availability Zones for VPC"
 default     = ["us-east-1a", "us-east-1b"]
}

variable "vpc_cidr_block" {
  type        = string
  description = "CIDR block for the VPC"
  default     = "10.0.0.0/16"  
}

variable "public_subnet_cidrs" {
 type        = list(string)
 description = "Public Subnet CIDR values"
 default     = ["10.0.1.0/24", "10.0.2.0/24"]
}


variable "private_subnet_cidrs" {
 type        = list(string)
 description = "Private Subnet CIDR values"
 default     = ["10.0.3.0/24", "10.0.4.0/24"]
}


variable "env" {
  type    = string
  default = "production"
}