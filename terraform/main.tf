
provider "aws" {

    region = "us-east-1"
  
}

resource "aws_key_pair" "example" {
  key_name   = "hayden-terraform"  # Replace with your desired key name
  public_key = file("~/.ssh/id_rsa.pub")  # Replace with the path to your public key file
}

resource "aws_vpc" "myvpc1" {

    cidr_block = "10.0.0.0/18"
  
}

resource "aws_subnet" "sub1" {

   vpc_id = aws_vpc.myvpc1.id
   cidr_block = "10.0.1.0/24"
   availability_zone       = "us-east-1a"
   map_public_ip_on_launch = true
  
}

resource "aws_internet_gateway" "igw" {

    vpc_id = aws_vpc.myvpc1.id
  
}

resource "aws_route_table" "RT" {
    vpc_id = aws_vpc.myvpc1.id

    route {
       cidr_block = "0.0.0.0/0"
       gateway_id = aws_internet_gateway.igw.id
    }
  
}

resource "aws_route_table_association" "RTA" {

    subnet_id = aws_subnet.sub1.id
    route_table_id = aws_route_table.RT.id
  
}

resource "aws_security_group" "sg" {
    name = "sg"
    vpc_id = aws_vpc.myvpc1.id

    ingress {
        from_port        = 80
        to_port          = 80
        protocol         = "tcp"
        cidr_blocks      = ["0.0.0.0/0"]
    }

    ingress {
        from_port        = 22
        to_port          = 22
        protocol         = "tcp"
        cidr_blocks      = ["0.0.0.0/0"]
    }

    egress {
        from_port        = 0
        to_port          = 0
        protocol         = -1
        cidr_blocks      = ["0.0.0.0/0"]
    }
  
}


resource "aws_instance" "ec2" {

    ami = "ami-0fc5d935ebf8bc3bc"
    instance_type = "t2.micro"
    key_name      = aws_key_pair.example.key_name
    vpc_security_group_ids = [aws_security_group.sg.id]
    subnet_id = aws_subnet.sub1.id

   connection {
    type        = "ssh"
    user        = "ubuntu"  
    private_key = file("~/.ssh/id_rsa")  
    host        = self.public_ip
  }
  provisioner "remote-exec" {
    inline = [
      "echo 'Hello from the remote instance'",
      "sudo apt update -y",  # Update package lists (for ubuntu) 
      "cd /home/ubuntu",
      "sudo apt install git -y",
      "sudo apt install docker.io -y",
      "rm -rf website-protofoilo",
      "git clone https://github.com/Haydenpal/website-protofoilo.git",
      "cd website-protofoilo",
      "sudo apt install docker-compose -y",
      "sudo docker-compose up -d --build --force-recreate",
      "exit",
    ]
  }
}




