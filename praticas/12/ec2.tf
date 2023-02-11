resource "aws_instance" "ec2" {
  ami           = "ami-0b0d54b52c62864d6"
  instance_type = "t2.micro"
  key_name = "azl6-key"

  tags = {
    "Name" = "TERRAFORM"
  }


  connection {
    type     = "ssh"
    user     = "ec2-user"
    host     = self.public_ip
  }

#   provisioner "remote-exec" {

#     inline = [
#       "touch /tmp/whenDidIFirstGotUp.txt",
#       "echo \"this instance got first up at $(date)\" >> /tmp/whenDidIFirstGotUp.txt"
#     ]
#   }

  provisioner "local-exec" {

    command = "touch whenIFirstBooted.txt && echo \"My instance first booted up on $(date)\" >> whenIFirstBooted.txt"
  }

}