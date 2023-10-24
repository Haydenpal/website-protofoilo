provider "aws" {
    region = "us-east-1"
    access_key = "AKIASBFWGMKJETKKBIFP"
    secret_key = "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"
  
}

resource "aws_instance" "ec2" {

    ami = "ami-0fc5d935ebf8bc3bc"
    instance_type = "t2.micro"
}
