resource "aws_security_group" "MySecurityGroup" {

  name        = "terraformSecurityGroup"
  description = "This was made through TF"

  ingress {
    description      = "TLS from VPC"
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = [aws_vpc.main.cidr_block]
    ipv6_cidr_blocks = [aws_vpc.main.ipv6_cidr_block]
  }

} # continue finishing this module...