terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "4.52.0"
    }
  }
}

locals { # Variáveis locais
  mytags = {
    Name = "MyName"
    Environment = "Production"
  }
}

provider "aws" {
  region = "sa-east-1"
}

resource "aws_instance" "name" {
    ami = "ami-0b0d54b52c62864d6"
    instance_type = "t2.micro"

    tags = local.mytags
}