provider "aws" {
  region = var.region
}

resource "aws_security_group" "dokku_allow_ssh" {
  name        = "dokku_allow_ssh"
  description = "Allow inbound ssh"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Dokku Allow SSH"
  }
}

resource "aws_security_group" "dokku_allow_http" {
  name        = "dokku_allow_http"
  description = "Allow inbound http"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Dokku Allow HTTP"
  }
}

resource "aws_security_group" "dokku_allow_outbound" {
  name        = "dokku_allow_outbound"
  description = "Allow all outbound traffic"
  vpc_id      = var.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Dokku Allow Outbound"
  }
}

resource "aws_instance" "dokku" {
  ami           = var.image
  instance_type = var.instance_type
  key_name      = var.key_name

  security_groups = [
    aws_security_group.dokku_allow_ssh.name,
    aws_security_group.dokku_allow_http.name,
    aws_security_group.dokku_allow_outbound.name,
  ]

  tags = {
    Name = "Dokku"
  }

  root_block_device {
    volume_size = 60
  }
}

resource "aws_eip" "dokku" {
  instance = aws_instance.dokku.id
}

resource "aws_route53_record" "dokku" {
  zone_id = var.zone["id"]
  name    = "dokku.${var.zone["name"]}"
  type    = "A"
  ttl     = "300"
  records = [aws_eip.dokku.public_ip]
}

resource "aws_route53_record" "dokku_wildcard" {
  zone_id = var.zone["id"]
  name    = "*.dokku.${var.zone["name"]}"
  type    = "A"
  ttl     = "300"
  records = [aws_eip.dokku.public_ip]
}