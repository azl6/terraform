resource "aws_instance" "ec2" {
  ami           = "ami-0b0d54b52c62864d6"
  instance_type = "t2.micro"

  tags = {
    "Name" = "tf"
  }
}