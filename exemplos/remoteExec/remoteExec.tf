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

  ami           = "ami-0b0d54b52c62864d6"
  instance_type = "t2.micro"
  key_name = "MyKeyInAWS" # Deve ser fornecido o nome da chave usada


  connection {
    type        = "ssh"
    user        = "ec2-user"
    host        = self.public_ip
    private_key = file("./private/key/here") # Chave privada
  }

  provisioner "remote-exec" {
    inline = [
      "COMMAND 1",
      "COMMAND 2",
      "COMMAND N"
    ]
  }

}