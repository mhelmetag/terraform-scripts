provider "aws" {
  region = "${var.region}"
}

resource "aws_security_group" "allow_ssh" {
  name        = "allow_ssh"
  description = "Allow inbound ssh"
  vpc_id      = "${var.vpc_id}"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name = "Allow SSH"
  }
}

resource "aws_security_group" "allow_http" {
  name        = "allow_http"
  description = "Allow inbound http"
  vpc_id      = "${var.vpc_id}"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name = "Allow HTTP"
  }
}

resource "aws_security_group" "allow_outbound" {
  name        = "allow_outbound"
  description = "Allow all outbound traffic"
  vpc_id      = "${var.vpc_id}"

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name = "Allow Outbound"
  }
}

resource "aws_instance" "surfliner_build" {
  ami           = "${var.images["build"]}"
  instance_type = "${var.instance_type}"
  key_name      = "mhelmetag-key-pair-uswest2"

  security_groups = [
    "${aws_security_group.allow_ssh.name}",
    "${aws_security_group.allow_outbound.name}"
  ]

  provisioner "local-exec" {
    command = "echo ${aws_instance.surfliner_build.public_ip} > build_ip_address.txt"
  }

  tags {
    Name = "SurflineR Build"
  }
}

resource "aws_instance" "surfliner_prod" {
  ami           = "${var.images["prod"]}"
  instance_type = "${var.instance_type}"
  key_name      = "mhelmetag-key-pair-uswest2"

  security_groups = [
    "${aws_security_group.allow_ssh.name}",
    "${aws_security_group.allow_http.name}",
    "${aws_security_group.allow_outbound.name}"
  ]

  provisioner "local-exec" {
    command = "echo ${aws_instance.surfliner_prod.public_ip} > prod_ip_address.txt"
  }

  tags {
    Name = "SurflineR Prod"
  }
}

resource "aws_eip" "surfliner_build" {
  instance = "${aws_instance.surfliner_build.id}"
}

resource "aws_eip" "surfliner_prod" {
  instance = "${aws_instance.surfliner_prod.id}"
}

resource "aws_route53_record" "surfliner_build" {
  zone_id = "${var.maxworld_zone["id"]}"
  name    = "build.surfliner.${var.maxworld_zone["name"]}"
  type    = "A"
  ttl     = "300"
  records = ["${aws_eip.surfliner_build.public_ip}"]
}

resource "aws_route53_record" "surfliner_prod" {
  zone_id = "${var.maxworld_zone["id"]}"
  name    = "surfliner.${var.maxworld_zone["name"]}"
  type    = "A"
  ttl     = "300"
  records = ["${aws_eip.surfliner_prod.public_ip}"]
}
