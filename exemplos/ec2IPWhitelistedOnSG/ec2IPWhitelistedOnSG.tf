terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "4.52.0"
    }
  }
}

provider "aws" {
  region = "sa-east-1"
}

resource "aws_instance" "myEc2" {
    ami = "ami-0b0d54b52c62864d6"
    instance_type = "t2.micro"
}

resource "aws_security_group" "mySG" {
  name = "terraform-sg"

  ingress { # Definição das inbount rules
    from_port = 80 # Referenciei o IP gerado da EC2 acima
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["${aws_instance.myEc2.public_ip}/32"]
  }
}

output "EC2_IP" {
  value = aws_instance.myEc2.public_ip
}

output "SG_VPC_ID" {
  value = aws_security_group.mySG.vpc_id
}