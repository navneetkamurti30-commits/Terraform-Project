# Main VPC
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags                 = { Name = "internal-architecture-vpc" }
}

# --- Internet Gateway (Essential for NAT Gateways) ---
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
  tags   = { Name = "main-igw" }
}

# --- Public Subnets (For NAT Gateways) ---
resource "aws_subnet" "public_az1" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "${var.aws_region}a"
  map_public_ip_on_launch = true
  tags                    = { Name = "public-nat-az1" }
}

resource "aws_subnet" "public_az2" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "${var.aws_region}b"
  map_public_ip_on_launch = true
  tags                    = { Name = "public-nat-az2" }
}

# --- Public Route Table (Connects Public Subnets to Internet Gateway) ---
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = { Name = "public-route-table" }
}

resource "aws_route_table_association" "public_az1" {
  subnet_id      = aws_subnet.public_az1.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table_association" "public_az2" {
  subnet_id      = aws_subnet.public_az2.id
  route_table_id = aws_route_table.public_rt.id
}

# --- Private Subnets ---
resource "aws_subnet" "private_web_az1" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.3.0/24"
  availability_zone = "${var.aws_region}a"
  tags              = { Name = "private-web-az1" }
}

resource "aws_subnet" "private_web_az2" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.4.0/24"
  availability_zone = "${var.aws_region}b"
  tags              = { Name = "private-web-az2" }
}

resource "aws_subnet" "private_app_az1" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.5.0/24"
  availability_zone = "${var.aws_region}a"
  tags              = { Name = "private-app-az1" }
}

resource "aws_subnet" "private_app_az2" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.6.0/24"
  availability_zone = "${var.aws_region}b"
  tags              = { Name = "private-app-az2" }
}

resource "aws_subnet" "private_db_az1" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.7.0/24"
  availability_zone = "${var.aws_region}a"
  tags              = { Name = "private-db-az1" }
}

resource "aws_subnet" "private_db_az2" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.8.0/24"
  availability_zone = "${var.aws_region}b"
  tags              = { Name = "private-db-az2" }
}

# --- NAT Gateways ---
resource "aws_eip" "nat1" { domain = "vpc" }
resource "aws_eip" "nat2" { domain = "vpc" }

resource "aws_nat_gateway" "nat1" {
  allocation_id = aws_eip.nat1.id
  subnet_id     = aws_subnet.public_az1.id
  tags          = { Name = "nat-gateway-az1" }
  depends_on    = [aws_internet_gateway.igw]
}

resource "aws_nat_gateway" "nat2" {
  allocation_id = aws_eip.nat2.id
  subnet_id     = aws_subnet.public_az2.id
  tags          = { Name = "nat-gateway-az2" }
  depends_on    = [aws_internet_gateway.igw]
}

# --- Private Route Tables (Directs Outbound Traffic to NAT Gateways) ---
resource "aws_route_table" "private_rt1" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat1.id
  }

  tags = { Name = "private-route-table-az1" }
}

resource "aws_route_table" "private_rt2" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat2.id
  }

  tags = { Name = "private-route-table-az2" }
}

# --- Route Table Associations for Private Subnets ---
resource "aws_route_table_association" "web_az1" {
  subnet_id      = aws_subnet.private_web_az1.id
  route_table_id = aws_route_table.private_rt1.id
}

resource "aws_route_table_association" "app_az1" {
  subnet_id      = aws_subnet.private_app_az1.id
  route_table_id = aws_route_table.private_rt1.id
}

resource "aws_route_table_association" "web_az2" {
  subnet_id      = aws_subnet.private_web_az2.id
  route_table_id = aws_route_table.private_rt2.id
}

resource "aws_route_table_association" "app_az2" {
  subnet_id      = aws_subnet.private_app_az2.id
  route_table_id = aws_route_table.private_rt2.id
}