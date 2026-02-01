# VPC
resource "aws_vpc" "swan_vpc" {
  cidr_block           = var.swan_vpc_cidr_block
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "${var.swan_name_prefix}-swan_vpc"
  }
}

# Public Subnets
resource "aws_subnet" "swan_public_subnets" {
  count                   = length(var.swan_public_subnet_cidr_blocks)
  vpc_id                  = aws_vpc.swan_vpc.id
  cidr_block              = var.swan_public_subnet_cidr_blocks[count.index]
  availability_zone       = var.swan_availability_zones[count.index]
  map_public_ip_on_launch = true

  tags = merge(
    var.swan_public_subnet_tags,
    {
      Name = "${var.swan_name_prefix}-swan_public_subnet-${count.index + 1}"
    }
  )
}

# Private Subnets
resource "aws_subnet" "swan_private_subnets" {
  count             = length(var.swan_private_subnet_cidr_blocks)
  vpc_id            = aws_vpc.swan_vpc.id
  cidr_block        = var.swan_private_subnet_cidr_blocks[count.index]
  availability_zone = var.swan_availability_zones[count.index]

  tags = merge(
    var.swan_private_subnet_tags,
    {
      Name = "${var.swan_name_prefix}-swan_private_subnet-${count.index + 1}"
    }
  )
}

# Internet Gateway
resource "aws_internet_gateway" "swan_igw" {
  vpc_id = aws_vpc.swan_vpc.id

  tags = {
    Name = "${var.swan_name_prefix}-swan_igw"
  }
}

# Regional NAT Gateway
resource "aws_nat_gateway" "swan_rnat" {
  vpc_id            = aws_vpc.swan_vpc.id
  availability_mode = "regional"

  tags = {
    Name = "${var.swan_name_prefix}-swan_rnat"
  }
}

# Public Route Tables
resource "aws_route_table" "swan_public_route_table" {
  vpc_id = aws_vpc.swan_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.swan_igw.id
  }

  tags = {
    Name = "${var.swan_name_prefix}-swan_public_route_table"
  }
}

resource "aws_route_table_association" "swan_public_route_table_association" {
  count          = length(var.swan_public_subnet_cidr_blocks)
  subnet_id      = aws_subnet.swan_public_subnets[count.index].id
  route_table_id = aws_route_table.swan_public_route_table.id
}

# Private Route Tables
resource "aws_route_table" "swan_private_route_table" {
  vpc_id = aws_vpc.swan_vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.swan_rnat.id
  }

  tags = {
    Name = "${var.swan_name_prefix}-swan_private_route_table"
  }
}

resource "aws_route_table_association" "swan_private_route_table_association" {
  count          = length(var.swan_private_subnet_cidr_blocks)
  subnet_id      = aws_subnet.swan_private_subnets[count.index].id
  route_table_id = aws_route_table.swan_private_route_table.id
}