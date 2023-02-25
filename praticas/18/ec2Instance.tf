resource "aws_instance" "myEc2" {
  ami           = "ami-0b0d54b52c62864d6"
  instance_type = "t2.micro"
  count         = 2

  tags = {
    "Name" = var.ec2Names[count.index]
  }
}

output "ips" {
    value = aws_instance.myEc2[*].public_ip
}