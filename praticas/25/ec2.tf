resource "aws_instance" "CUSTOMEC2NAME" {
  ami           = "ami-0b0d54b52c62864d6"
  instance_type = var.instance_type
  key_name = "TF-KEY"

  tags = {
    "Name" = "TFNAME"
  }

  connection {
    type     = "ssh"
    user     = "ec2-user"
    host     = self.public_ip
  }

  provisioner "remote-exec" {
    inline = [
      "touch /tmp/remote-exec-print.txt && echo \"This was printed by the remote-exec!\" >> /tmp/remote-exec-print.txt"
    ]
  }
}

output "public_ipv4" {
  value = aws_instance.CUSTOMEC2NAME.public_ip
}