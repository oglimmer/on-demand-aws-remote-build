provider "aws" {
  region = "eu-central-1"
}

resource "aws_security_group" "picz_build_sg" {
  name = "picz-build-sg"
  description = "Security group for picz build instance"
  vpc_id = aws_default_vpc.default.id

  ingress {
    from_port = 22
    to_port   = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    to_port   = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "picz-build-sg"
  }
}

resource "aws_default_vpc" "default" {}

resource "aws_instance" "picz_build_instance" {
  ami           = "ami-04bd057ffbd865312" # debian 12 ARM64
  instance_type = "t4g.xlarge" # 4 vCPUs, 16 GB RAM
  key_name      = "oli-mac-default" # SSH key pair

  security_groups = [aws_security_group.picz_build_sg.name]

  tags = {
    Name = "picz-build-instance"
  }
}

output "public_ip" {
  value = aws_instance.picz_build_instance.public_ip
}
