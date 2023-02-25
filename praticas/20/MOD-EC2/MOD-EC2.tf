resource "aws_instance" "myEc2" {
  ami           = "ami-0b0d54b52c62864d6"
  instance_type = var.customVar

}

output "InstanceTypeOutput" {
    value = aws_instance.myEc2.instance_type
}