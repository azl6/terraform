resource "aws_security_group" "MySecurityGroup" {
  name        = "sshFromAnywhere"
  description = "Allow SSH traffic from anywhere"

  ingress {
    description = "SSH from anywhere"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [ "0.0.0.0/0" ] 
  }
}

  output "securityGroupName" {
    value = aws_security_group.MySecurityGroup.name
  }