terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }

    ansible = {
      source  = "ansible/ansible"
      version = "~>1.3.0"
    }
  }

  required_version = ">= 1.2.0"
}

provider "aws" {
  region = var.region
}

resource "aws_security_group" "sliver" {
  name = "sliver-sg"
  ingress {
    from_port   = 0
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.cidr_block]
  }

  ingress {
    from_port   = 0
    to_port     = 31337
    protocol    = "tcp"
    cidr_blocks = [var.cidr_block]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "sliver" {
  ami                    = var.ami
  instance_type          = var.instance_type
  key_name               = var.key
  vpc_security_group_ids = [aws_security_group.sliver.id]

  tags = {
    Name = var.instance_name
  }
}

resource "ansible_host" "sliver" {
  name   = aws_instance.sliver.public_ip
  groups = ["c2"]
  variables = {
    ansible_user                 = "ubuntu"
    ansible_ssh_private_key_file = var.ssh_key_path
    ansible_python_interpreter   = "/usr/bin/python3"
    ansible_ssh_common_args      = "-o StrictHostKeyChecking=no"
  }
}

// Example: Wait for SSH to be available before running Ansible
resource "null_resource" "wait_for_ssh" {
  depends_on = [aws_instance.sliver]

  provisioner "remote-exec" {
    inline = ["echo 'SSH is up'"]
    connection {
      type        = "ssh"
      user        = "ubuntu"               // Adjust for your AMI
      private_key = file(var.ssh_key_path) // Path to your private key
      host        = aws_instance.sliver.public_ip
    }
  }
}

resource "null_resource" "ansible_provision_local_exec" {
  depends_on = [null_resource.wait_for_ssh] // Depends on SSH being ready

  triggers = {
    instance_id = aws_instance.sliver.id
  }

  provisioner "local-exec" {
    command = <<EOT
      ansible-playbook ansible/site.yml \
        -i ansible/inventory.yml
    EOT
    #working_dir = "${path.module}/ansible" // Assuming Ansible files are in ../ansible
    on_failure = continue // Or 'fail' if you want Terraform to stop
  }
}
