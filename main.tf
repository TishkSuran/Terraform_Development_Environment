locals {
  cidr     = "10.123.0.0/16"
  az       = "eu-west-2a"
  instance = "t2.micro"
}

data "aws_availability_zones" "available" {}

data "aws_availability_zones" "good_zones" {
  filter {
    name   = "state"
    values = ["available"]
  }

  filter {
    name   = "opt-in-status"
    values = ["opt-in-not-required"]
  }
}

resource "aws_vpc" "main_vpc" {
  cidr_block           = local.cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "Dev"
  }
}

resource "aws_subnet" "main_subnet" {
  vpc_id                  = aws_vpc.main_vpc.id
  cidr_block              = local.cidr
  map_public_ip_on_launch = true
  availability_zone       = data.aws_availability_zones.good_zones.names[0]

  tags = {
    Name = "Subnet"
  }
}

resource "aws_internet_gateway" "main_internet_gateway" {
  vpc_id = aws_vpc.main_vpc.id

  tags = {
    Name = "Dev IGW"
  }
}

resource "aws_route_table" "main_route_table" {
  vpc_id = aws_vpc.main_vpc.id

  tags = {
    Name = "dev_public_rt"
  }
}

resource "aws_route" "main_route" {
  route_table_id         = aws_route_table.main_route_table.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.main_internet_gateway.id

}

resource "aws_route_table_association" "main_rta" {
  route_table_id = aws_route_table.main_route_table.id
  subnet_id      = aws_subnet.main_subnet.id

}

resource "aws_security_group" "main_security_group" {
  name        = "main_security_group"
  description = "Main Security Group"
  vpc_id      = aws_vpc.main_vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${var.my_ip_address}/32"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_key_pair" "auth" {
  key_name   = "key"
  public_key = file("/Users/Coding/.ssh/key.pub")
}

resource "aws_instance" "aws" {
  ami           = data.aws_ami.server_ami.id
  instance_type = local.instance

  key_name               = aws_key_pair.auth.id
  vpc_security_group_ids = [aws_security_group.main_security_group.id]
  subnet_id              = aws_subnet.main_subnet.id
  user_data              = file("userdata.tpl")

  tags = {
    Name = "Dev-Node"
  }

  root_block_device {
    volume_size = 10
  }

  provisioner "local-exec" {
    command = templatefile("/Users/Coding/Desktop/Terraform_Dev_Enviroment/ssh.tpl", {
      hostname     = self.public_ip,
      user         = "ubuntu",
      identityfile = "/Users/Coding/.ssh/key"
    })
    interpreter = ["bash", "-c"]
  }


}
