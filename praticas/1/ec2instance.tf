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
   count = 3

   tags = {
     "Name" = var.ec2Names["${count.index}"]
     "Environment" = "Development"
   }
}

output "ec2Arn" {
  value = aws_instance.myEc2[*].arn
}

output "ec2PublicIP" {
  value = aws_instance.myEc2[*].public_ip
}