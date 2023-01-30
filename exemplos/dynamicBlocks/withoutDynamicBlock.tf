/*terraform {
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

resource "aws_security_group" "mySg" {
  name        = "terraform-sg"

    ingress {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = [ "222.222.222.222/32" ]
    }

    ingress {
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_blocks = [ "222.222.222.222/32" ]
    }

    ingress {
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      cidr_blocks = [ "222.222.222.222/32" ]
    }
  }
*/