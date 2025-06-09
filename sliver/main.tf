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

    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 5"
    }
  }

  required_version = ">= 1.2.0"
}

provider "aws" {
  region = var.aws_region
}

provider "cloudflare" {
  # token pulled from $CLOUDFLARE_API_TOKEN
}

resource "aws_security_group" "sliver" {
  name = "sliver-sg"
  # SSH Access
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.aws_cidr_block]
  }

  # Team Server Access
  ingress {
    from_port   = 31337
    to_port     = 31337
    protocol    = "tcp"
    cidr_blocks = [var.aws_cidr_block]
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
  ami                    = var.aws_ami
  instance_type          = var.aws_instance_type
  key_name               = var.aws_key_pair
  vpc_security_group_ids = [aws_security_group.sliver.id]

  tags = {
    Name = var.aws_instance_name
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

resource "cloudflare_dns_record" "update_dns_record" {
  zone_id = var.cloudflare_zone_id
  content = aws_instance.sliver.public_ip
  name    = var.cloudflare_name
  proxied = true
  ttl     = 1
  type    = var.cloudflare_type
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
    command    = <<EOT
      ansible-playbook ansible/site.yml \
        -i ansible/inventory.yml \
        -e c2_user_agent=${var.c2_user_agent}
    EOT
    on_failure = fail
  }
}
