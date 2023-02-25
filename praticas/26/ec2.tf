resource "aws_instance" "CUSTOMEC2NAME" {
  ami           = "ami-0b0d54b52c62864d6"
  instance_type = var.instance_type

  tags = {
    "Name" = "TFNAME"
  }

  provisioner "local-exec" {
      command = "if [[ -f /tmp/managedIPs ]]; then echo ${aws_instance.CUSTOMEC2NAME.public_ip} >> /tmp/managedIPs; else touch /tmp/managedIPs && echo ${aws_instance.CUSTOMEC2NAME.public_ip} >> /tmp/managedIPs; fi"
  }
}

output "public_ipv4" {
  value = aws_instance.CUSTOMEC2NAME.public_ip
}