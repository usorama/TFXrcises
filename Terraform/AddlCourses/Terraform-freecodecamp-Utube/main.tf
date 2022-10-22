# AWS VPC

resource "aws_vpc" "uu-vpc" {
  cidr_block           = "10.123.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    "Name" = "uu-dev"
  }
}

resource "aws_subnet" "uu-public-subnet" {
  vpc_id                  = aws_vpc.uu-vpc.id
  cidr_block              = "10.123.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "ap-south-1a"

  tags = {
    "Name" = "dev-public-subnet"
  }
}

resource "aws_internet_gateway" "uu-internet-gateway" {
  vpc_id = aws_vpc.uu-vpc.id

  tags = {
    "Name" = "uu-dev-int-gateway"
  }
}

resource "aws_route_table" "uu-pub-routetable" {
  vpc_id = aws_vpc.uu-vpc.id

  tags = {
    "Name" = "uu-dev-pub-rt"
  }
}

resource "aws_route" "uu-default-route" {
  route_table_id         = aws_route_table.uu-pub-routetable.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.uu-internet-gateway.id
}

resource "aws_route_table_association" "uu-pub-assoc" {
  subnet_id      = aws_subnet.uu-public-subnet.id
  route_table_id = aws_route_table.uu-pub-routetable.id
}

resource "aws_security_group" "uu-sec-grp" {
  name        = "uu_dev_sg_allow_tls"
  description = "Allow TLS inbound traffic"
  vpc_id      = aws_vpc.uu-vpc.id

  ingress {
    description = "TLS from VPC"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "uu_dev_sg_allow_tls"
  }
}

resource "aws_instance" "uu-dev-instance" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t2.micro"
  key_name               = aws_key_pair.uu_ed25519_auth.key_name
  vpc_security_group_ids = [aws_security_group.uu-sec-grp.id]
  subnet_id              = aws_subnet.uu-public-subnet.id
  user_data              = file("userdata.tpl")

  root_block_device {
    volume_size = 10
  }
  tags = {
    "Name" = "uu-dev-instance"
  }

  provisioner "local-exec" {
    command = templatefile("${var.host_os}-ssh-config.tpl", {
      hostname      = self.public_ip,
      user          = "ubuntu"
      identityfile = "~/.ssh/uu_edkey"
    })
#    interpreter = ["Powershell", "-Command"]
# Interpreter with condition based on OS
    interpreter = var.host_os == "windows" ? ["Powershell", "-Command"] : ["bash", "-c"]
  }
}

resource "aws_key_pair" "uu_ed25519_auth" {
  key_name   = "uu-ed-key"
  public_key = file("~/.ssh/uu_edkey.pub")
}

