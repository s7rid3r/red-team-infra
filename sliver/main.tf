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
  # SSH Access
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.cidr_block]
  }

  # Team Server Access
  ingress {
    from_port   = 31337
    to_port     = 31337
    protocol    = "tcp"
    cidr_blocks = [var.cidr_block]
  }
  # HTTPS Access
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # HTTP Access
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # DNS Access
  ingress {
    from_port   = 53
    to_port     = 53
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow any outbound
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

# Wait for SSH to be available before running Ansible
resource "null_resource" "wait_for_ssh" {
  depends_on = [aws_instance.sliver]

  provisioner "remote-exec" {
    inline = ["echo 'SSH is up'"]
    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = file(var.ssh_key_path)
      host        = aws_instance.sliver.public_ip
    }
  }
}

resource "null_resource" "ansible_provision_local_exec" {
  depends_on = [null_resource.wait_for_ssh]

  triggers = {
    instance_id = aws_instance.sliver.id
  }

  provisioner "local-exec" {
    command = <<EOT
      ansible-playbook ansible/site.yml \
        -i ansible/inventory.yml
    EOT
    on_failure = fail
  }
}
