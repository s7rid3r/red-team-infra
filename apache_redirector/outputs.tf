output "instance_name" {
  description = "Name of the EC2 instance"
  value       = var.aws_instance_name
}

output "instance_id" {
  description = "ID of the EC2 instance"
  value       = aws_instance.redirector.id
}

output "instance_public_ip" {
  description = "Public IP address of the EC2 instance"
  value       = aws_instance.redirector.public_ip
}
