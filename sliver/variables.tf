variable "aws_region" {
  description = "AMI ID to use to create the EC2 instance"
  type        = string
  default     = "us-east-1"
}

variable "aws_ami" {
  description = "AMI ID to use to create the EC2 instance"
  type        = string
  default     = "ami-0731becbf832f281e" // Ubuntu 24.04 latest
}

variable "aws_instance_name" {
  description = "Value of the Name tag for the EC2 instance"
  type        = string
  default     = "sliver"
}

variable "aws_instance_type" {
  description = "Value of the instance type for the EC2 instance"
  type        = string
  default     = "t2.micro"
}

variable "aws_key_pair" {
  description = "Key to use to connect to the EC2 instance"
  type        = string
  default     = "Test"
}

variable "aws_cidr_block" {
  description = "Your CIDR block to use for security groups SSH access"
  type        = string
  default     = "0.0.0.0/0"
}

# Cloudflare Variables
variable "cloudflare_zone_id" {
  description = "Cloudflare Zone ID associated with the domain name used"
  type        = string
  default     = "8b717207bcee4047af2e9dff95822996"
}

variable "cloudflare_type" {
  description = "DNS record type associated with the domain name used"
  type        = string
  default     = "A"
}

variable "cloudflare_name" {
  description = "Domain name that should be updated"
  type        = string
  default     = "foo.example.com"
}

# C2 Variables
variable "c2_users" {
  description = "Names to be created as sliver operators"
  type        = list(string)
  default     = []
}

variable "c2_user_agent" {
  description = "User-agent string that will pass the mod_rewrite rules to be sent to C2 server"
  type        = string
  default     = "NotC2Traffic"
}

# Local Variables
variable "ssh_key_path" {
  description = "Local directory where ssh key used to connect to EC2 instance is stored"
  type        = string
  default     = "~/.ssh/Test.pem"
}
