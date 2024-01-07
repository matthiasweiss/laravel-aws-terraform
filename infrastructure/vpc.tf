# returns availabe availability zones for current region
data "aws_availability_zones" "available" {}

resource "aws_vpc" "default_vpc" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_subnet" "public_subnet_az_a" {
  vpc_id            = aws_vpc.default_vpc.id
  availability_zone = data.aws_availability_zones.available.names[0]
  cidr_block        = "10.0.0.0/24"
}

resource "aws_subnet" "public_subnet_az_b" {
  vpc_id            = aws_vpc.default_vpc.id
  availability_zone = data.aws_availability_zones.available.names[1]
  cidr_block        = "10.0.1.0/24"
}

resource "aws_subnet" "private_subnet_az_a" {
  vpc_id            = aws_vpc.default_vpc.id
  availability_zone = data.aws_availability_zones.available.names[0]
  cidr_block        = "10.0.2.0/24"
}

resource "aws_subnet" "private_subnet_az_b" {
  vpc_id            = aws_vpc.default_vpc.id
  availability_zone = data.aws_availability_zones.available.names[1]
  cidr_block        = "10.0.3.0/24"
}

resource "aws_internet_gateway" "internet_gateway" {
  vpc_id = aws_vpc.default_vpc.id
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.default_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.internet_gateway.id
  }
}

resource "aws_route_table_association" "public_subnet_az_a_association" {
  subnet_id      = aws_subnet.public_subnet_az_a.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "public_subnet_az_b_association" {
  subnet_id      = aws_subnet.public_subnet_az_b.id
  route_table_id = aws_route_table.public.id
}

resource "aws_security_group" "default" {
  vpc_id = aws_vpc.default_vpc.id
  ingress {
    from_port = "0"
    to_port   = "0"
    protocol  = "-1"
    self      = true
  }

  egress {
    from_port = "0"
    to_port   = "0"
    protocol  = "-1"
    self      = "true"
  }
}