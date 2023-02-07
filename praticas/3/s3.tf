resource "aws_s3_bucket" "myBucket" {
    bucket = "s3-terraform-backend-azl6"
    acl = "public-read-write"
}