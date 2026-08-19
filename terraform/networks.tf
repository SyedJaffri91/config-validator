# The VPC — your private network
#trivy:ignore:AWS-0178 VPC Flow Logs deferred for this learning project. Would enable in production for network audit/forensics. Accepted 2026-08-18.
resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "config-validator-vpc"
  }
}

# The internet gateway — the door to the internet
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "config-validator-igw"
  }
}

# Public subnet in availability zone A
#trivy:ignore:AWS-0164 Public IP required — no NAT gateway in this design, so tasks pull images via public subnets. Deliberate cost/simplicity tradeoff. Accepted 2026-08-18.
resource "aws_subnet" "public_a" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.0.0/20"
  availability_zone       = "eu-west-2a"
  map_public_ip_on_launch = true

  tags = {
    Name = "config-validator-public-a"
  }
}

# Public subnet in availability zone B
#trivy:ignore:AWS-0164 Public IP required — no NAT gateway in this design, so tasks pull images via public subnets. Deliberate cost/simplicity tradeoff. Accepted 2026-08-18.
resource "aws_subnet" "public_b" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.16.0/20"
  availability_zone       = "eu-west-2b"
  map_public_ip_on_launch = true

  tags = {
    Name = "config-validator-public-b"
  }
}

# Route table — sends internet-bound traffic to the internet gateway
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name = "config-validator-public-rt"
  }
}

# Connect subnet A to the route table
resource "aws_route_table_association" "public_a" {
  subnet_id      = aws_subnet.public_a.id
  route_table_id = aws_route_table.public.id
}

# Connect subnet B to the route table
resource "aws_route_table_association" "public_b" {
  subnet_id      = aws_subnet.public_b.id
  route_table_id = aws_route_table.public.id
}