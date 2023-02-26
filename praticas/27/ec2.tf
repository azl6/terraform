resource "aws_instance" "ec2" {
  ami           = "ami-0b0d54b52c62864d6"
  instance_type = "t2.micro"

  for_each = toset(var.ec2Names)

  tags = {
    "Name" = each.value
  }
}