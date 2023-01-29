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

resource "aws_security_group" "mySg" {
    
    ingress {
        description      = "Allow SSH into the instance from custom var IP"
        from_port        = 22
        to_port          = 22
        protocol         = "tcp"
        cidr_blocks      = [var.customIpCIDR] # Referenciando IP do variables.tf
    }

        ingress {
        description      = "Allow HTTP into the instance from custom var IP"
        from_port        = 80
        to_port          = 80
        protocol         = "tcp"
        cidr_blocks      = [var.customIpCIDR] # Referenciando IP do variables.tf
    }

        ingress {
        description      = "Allow HTTPS into the instance from custom var IP"
        from_port        = 443
        to_port          = 443
        protocol         = "tcp"
        cidr_blocks      = [var.customIpCIDR] # Referenciando IP do variables.tf
    }

}

output "SG_VPC_ID" {
    value = aws_security_group.mySg.vpc_id
}