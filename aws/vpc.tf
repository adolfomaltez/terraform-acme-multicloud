# VPC
resource "aws_vpc" "acme-vpc" {
  cidr_block       = "10.0.0.0/16"

  tags = {
    Name = "ACME VPC"
  }
}

# Public Subnets
resource "aws_subnet" "public_subnet_a" {
 vpc_id            = aws_vpc.acme-vpc.id
 cidr_block        = "10.0.11.0/24"
 availability_zone = "us-east-1a"

 tags = {
   Name = "Public Subnet A"
 }
}

resource "aws_subnet" "public_subnet_b" {
 vpc_id            = aws_vpc.acme-vpc.id
 cidr_block        = "10.0.12.0/24"
 availability_zone = "us-east-1b"

 tags = {
   Name = "Public Subnet B"
 }
}

# Private Subnets
resource "aws_subnet" "private_subnet_a" {
 vpc_id            = aws_vpc.acme-vpc.id
 cidr_block        = "10.0.21.0/24"
 availability_zone = "us-east-1a"

 tags = {
   Name = "Private Subnet A"
 }
}

resource "aws_subnet" "private_subnet_b" {
 vpc_id            = aws_vpc.acme-vpc.id
 cidr_block        = "10.0.22.0/24"
 availability_zone = "us-east-1b"

 tags = {
   Name = "Private Subnet B"
 }
}


# Internet Gateway
resource "aws_internet_gateway" "gw" {
 vpc_id = aws_vpc.acme-vpc.id

 tags = {
   Name = "ACME VPC Internet Gateway"
 }
}


# Route Table
resource "aws_route_table" "second_rt" {
 vpc_id = aws_vpc.acme-vpc.id
 route {
   cidr_block = "0.0.0.0/0"
   gateway_id = aws_internet_gateway.gw.id
 }

 tags = {
   Name = "2nd Route Table"
 }
}

# Public Subnet route table asociation
resource "aws_route_table_association" "public_subnet_a" {
 subnet_id      = aws_subnet.public_subnet_a.id
 route_table_id = aws_route_table.second_rt.id
}

resource "aws_route_table_association" "public_subnet_b" {
 subnet_id      = aws_subnet.public_subnet_b.id
 route_table_id = aws_route_table.second_rt.id
}

resource "aws_route_table_association" "private_subnet_a" {
 subnet_id      = aws_subnet.private_subnet_a.id
 route_table_id = aws_route_table.second_rt.id
}

resource "aws_route_table_association" "private_subnet_b" {
 subnet_id      = aws_subnet.private_subnet_b.id
 route_table_id = aws_route_table.second_rt.id
}
