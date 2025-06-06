variable "region" {
  description = "AMI ID to use to create the EC2 instance"
  type        = string
  default     = "us-east-1"
}

variable "ami" {
  description = "AMI ID to use to create the EC2 instance"
  type        = string
  default     = "ami-0731becbf832f281e" // Ubuntu 24.04 latest
}

variable "instance_name" {
  description = "Value of the Name tag for the EC2 instance"
  type        = string
  default     = "sliver"
}

variable "instance_type" {
  description = "Value of the instance type for the EC2 instance"
  type        = string
  default     = "t2.micro"
}

variable "key" {
  description = "Key to use to connect to the EC2 instance"
  type        = string
  default     = "Test"
}

variable "ssh_key_path" {
  description = "Local directory where ssh key used to connect to EC2 instance is stored"
  type        = string
  default     = "~/.ssh/Test.pem"
}

variable "cidr_block" {
  description = "Your CIDR block to use for security groups SSH access"
  type = string
  default = "0.0.0.0/0"
}