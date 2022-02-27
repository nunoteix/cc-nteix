
# Cocus Challenge - Nuno Teixeira
#Setup provider
provider "aws" {
    region = "eu-central-1"
}

#VPC
resource "aws_vpc" "awslab-vpc"{
    cidr_block = "172.16.0.0/16"
    tags = {
      Name = "awslab-vpc"
  }
}

#Internet GW
resource "aws_internet_gateway" "awslab-igw"{
    vpc_id = aws_vpc.awslab-vpc.id
}

#Public Subnet
resource "aws_subnet" "awslab-subnet-public"{
    vpc_id = aws_vpc.awslab-vpc.id
    cidr_block = "172.16.1.0/24"
    tags = {
      Name = "awslab--subnet-public"
  }
}

#Private Subnet
resource "aws_subnet" "awslab-subnet-private"{
    vpc_id = aws_vpc.awslab-vpc.id
    cidr_block = "172.16.2.0/24"
    tags = {
      Name = "awslab--subnet-private"
  }
}

#Routing Table
resource "aws_route_table" "awslab-rt-internet"{
    vpc_id = aws_vpc.awslab-vpc.id
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.awslab-igw.id
    }
}

#Associate internet routing table to Public Subnet
resource "aws_route_table_association" "awslab-public-rt"{
    subnet_id = aws_subnet.awslab-subnet-public.id
    route_table_id = aws_route_table.awslab-rt-internet.id
}

#Public Ports Security Group
resource "aws_security_group" "awslab-sg-public"{
    name = "awslab-sg-public"
    description = "Public Ports"
    vpc_id = aws_vpc.awslab-vpc.id

    ingress{
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    ingress{
        from_port = 443
        to_port = 443
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    ingress{
        from_port = -1
        to_port = -1
        protocol = "icmp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    ingress{
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    egress{
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
}

#Private Ports Security Group
resource "aws_security_group" "awslab-sg-private"{
    name = "awslab-sg-private"
    description = "Private Ports"
    vpc_id = aws_vpc.awslab-vpc.id

    ingress{
        from_port = 3110
        to_port = 3110
        protocol = "tcp"
        cidr_blocks = ["172.16.1.0/24"]
    }

    ingress{
        from_port = -1
        to_port = -1
        protocol = "icmp"
        cidr_blocks = ["172.16.1.0/24"]
    }

    ingress{
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["172.16.1.0/24"]
    }

    egress{
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
}

#Webserver Instance
resource "aws_instance" "awslab-ec2-webserver" {
  ami           = "ami-018e652c3930c74be" #Ubuntu Server 20.04 LTS (HVM) + Apache (ports 80, 443)
  instance_type = "t2.micro"
  key_name = "cc-nteix-key"
  subnet_id = aws_subnet.awslab-subnet-public.id
  vpc_security_group_ids = [aws_security_group.awslab-sg-public.id]
  associate_public_ip_address = true
    
  tags = {
      Name = "awslab-ec2-webserver"
  }
}

#Database Instance
resource "aws_instance" "awslab-ec2-database" {
  ami           = "ami-0bf967ade203857e4" #Ubuntu Server 20.04 LTS (HVM) + MySQL 8 (port 3110)
  instance_type = "t2.micro"
  key_name = "cc-nteix-key"
  subnet_id = aws_subnet.awslab-subnet-private.id
  vpc_security_group_ids = [aws_security_group.awslab-sg-private.id]
  
  tags = {
      Name = "awslab-ec2-database"
  }
}