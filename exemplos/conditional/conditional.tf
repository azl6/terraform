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

resource "aws_instance" "testEc2" {
    ami = "ami-0b0d54b52c62864d6"
    instance_type = "t2.micro"
    count = var.isTest == true? 1 : 0 ## Condicional ternário básico.
}                                      # 
                                       # testEc2 só será provisionada se
resource "aws_instance" "devEc2" {     # isTest == true
    ami = "ami-0b0d54b52c62864d6"      # 
    instance_type = "t2.medium"         # devEc2 só será provisionada se
    count = var.isTest == true? 0 : 1 ## isTest == false
}