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
}                                      #-> Deployando o instance_type adequado
                                       #
resource "aws_instance" "myEc2" {      #############################
    ami = "ami-0b0d54b52c62864d6"                                  #
    instance_type = lookup(var.instanceTypes, terraform.workspace) #
}

