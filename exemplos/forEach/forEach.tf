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

resource "aws_instance" "myEc2" {

  for_each = var.ec2Tags # For each na variable

  ami           = "ami-0b0d54b52c62864d6"
  instance_type = "t2.micro"

  tags = {
      "Name"        = each.value.nome ######## Populando dados com o for_each
      "Environment" = each.value.environment # a partir da variable
  }
}
