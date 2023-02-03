terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.52.0"
    }
  }
}

provider "aws" {
  region = "sa-east-1"
}

resource "aws_key_pair" "ssh_key" {
  key_name   = "login-key"
  public_key = file("/home/azl6/chave.pub") # Chave pública
}

# Instância cujo IP será liberado nos inbound-rules do SG
resource "aws_instance" "ec2Two" {
  ami           = "ami-0b0d54b52c62864d6"
  instance_type = "t2.micro"
  key_name      = aws_key_pair.ssh_key.key_name # Referenciando a chave pública

  tags = {
    "Name" = "allowedOnSG"
  }
}

# SG
resource "aws_security_group" "sgOne" {
  name        = "terraform_sg"
  description = "Allow SSH, HTTP and HTTPS from aws_instance.ec2Two"

  dynamic "ingress" {

    for_each = var.ingressPorts
    iterator = port

    content {
      from_port   = port.value
      to_port     = port.value
      protocol    = "tcp"
      cidr_blocks = [format("%s/%s", aws_instance.ec2Two.public_ip, "32")]
    }
  }
}

#Instância attachada ao SG
resource "aws_instance" "ec2One" {
  ami             = "ami-0b0d54b52c62864d6"
  instance_type   = "t2.micro"
  security_groups = ["terraform_sg"]
  tags = {
    "Name" = "withSG"
  }
}

