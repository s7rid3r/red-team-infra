output "instance_name" {
  description = "ID of the EC2 instance"
  value       = aws_instance.sliver.id
}

output "instance_public_ip" {
  description = "Public IP address of the EC2 instance"
  value       = aws_instance.sliver.public_ip
}
