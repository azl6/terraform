terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.53.0"
    }
  }
}

provider "aws" {
  region = "sa-east-1"
}

resource "aws_instance" "myec2" {
  ami           = "ami-0b0d54b52c62864d6"
  instance_type = "t2.micro"

  provisioner "local-exec" {
    command = "COMANDO AQUI"
  }
}