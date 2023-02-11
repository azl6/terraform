resource "aws_instance" "MyEC2" {
  ami           = "ami-0b0d54b52c62864d6"
  instance_type = "t2.micro"

  tags = {
    "Name" = "hellowilly"
  }
}

output "tags" {
  value = aws_instance.MyEC2.tags_all
}