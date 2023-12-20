resource "aws_subnet" "public1" {
  vpc_id                  = aws_vpc.Demo.id
  cidr_block              = "10.0.0.0/24"
  availability_zone       = "ap-south-1a"
  map_public_ip_on_launch = true
}

resource "aws_subnet" "public2" {
  vpc_id                  = aws_vpc.Demo.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "ap-south-1b"
  map_public_ip_on_launch = true
}

resource "aws_subnet" "private1" {
  vpc_id                  = aws_vpc.Demo.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "ap-south-1a"
  map_public_ip_on_launch = false

}

resource "aws_subnet" "private2" {
  vpc_id                  = aws_vpc.Demo.id
  cidr_block              = "10.0.3.0/24"
  availability_zone       = "ap-south-1b"
  map_public_ip_on_launch = false

}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.Demo.id
}

resource "aws_route_table" "PubRT" {
  vpc_id = aws_vpc.Demo.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
}

resource "aws_route_table_association" "PubRT1" {
  subnet_id      = aws_subnet.public1.id
  route_table_id = aws_route_table.PubRT.id
}
resource "aws_route_table_association" "PubRT2" {
  subnet_id      = aws_subnet.public2.id
  route_table_id = aws_route_table.PubRT.id
}

resource "aws_route_table" "PvtRT" {
  vpc_id = aws_vpc.Demo.id
}

resource "aws_route_table_association" "PvtRT1" {
  subnet_id      = aws_subnet.private1.id
  route_table_id = aws_route_table.PvtRT.id
}
resource "aws_route_table_association" "PvtRT2" {
  subnet_id      = aws_subnet.private2.id
  route_table_id = aws_route_table.PvtRT.id
}

resource "aws_security_group" "webSg" {
  name   = "web"
  vpc_id = aws_vpc.Demo.id

  ingress {
    description = "Http from Vpc"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "ssh"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    description = "outgoing traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "PubSG"
  }
}
resource "aws_instance" "webserver1" {
  ami                    = "ami-03f4878755434977f"
  instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_security_group.webSg.id]
  subnet_id              = aws_subnet.public1.id
}
resource "aws_instance" "webserver2" {
  ami                    = "ami-03f4878755434977f"
  instance_type          = "t2micro"
  vpc_security_group_ids = [aws_security_group.webSg.id]
  subnet_id              = aws_subnet.public2.id
}
resource "aws_s3_bucket" "new_bucket" {
  bucket = "terraameerbucket"
}
