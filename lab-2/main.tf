provider "aws" {
    region = "ap-south-1"
}

resource "aws_vpc" "this" {
    cidr_block = "10.140.0.0/16"

    tags = {
        Name = "Lab2-VPC"
    }
}

resource "aws_subnet" "public" {
  vpc_id = aws_vpc.this.id
  cidr_block = "10.140.0.0/24"
  availability_zone = "ap-south-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "Lab-2-Public-Subnet"
  }
}

resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id

  tags = {
    Name = "Lab-2-IGW"
  }
}

resource "aws_route_table" "this" {
  vpc_id = aws_vpc.this.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.this.id
  }

  tags = {
    Name = "Lab-2-Public-RT"
  }
}

resource "aws_route_table_association" "this" {
  subnet_id = aws_subnet.public.id
  route_table_id = aws_route_table.this.id
}

resource "aws_security_group" "this" {
    vpc_id = aws_vpc.this.id

    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }

    tags = {
        Name = "Lab-2-SG"
    }

}

resource "aws_instance" "this" {
    ami = var.ami_id
    instance_type = var.instance_type

    subnet_id = aws_subnet.public.id
    vpc_security_group_ids = [aws_security_group.this.id]

    tags = {
      Name = var.ec2_name
    }
}