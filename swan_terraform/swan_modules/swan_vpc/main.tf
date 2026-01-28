resource "aws_vpc" "swan_vpc" {
  cidr_block           = var.swan_vpc_cidr_block
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "${var.swan_eks_cluster_name}-swan_vpc"
  }
}

data "aws_availability_zones" "swan_available_azs" {
  state = "available"
}

resource "aws_subnet" "swan_private_subnets" {
  count             = length(var.swan_private_subnet_cidr_blocks)
  vpc_id            = aws_vpc.swan_vpc.id
  cidr_block        = var.swan_private_subnet_cidr_blocks[count.index]
  availability_zone = data.aws_availability_zones.swan_available_azs.names[count.index]

  tags = {
    Name = "${var.swan_eks_cluster_name}-swan_private_subnet-${count.index + 1}"
  }
}

resource "aws_internet_gateway" "swan_igw" {
  vpc_id = aws_vpc.swan_vpc.id

  tags = {
    Name = "${var.swan_eks_cluster_name}-swan_igw"
  }
}

resource "aws_nat_gateway" "swan_rnat" {
  vpc_id            = aws_vpc.swan_vpc.id
  availability_mode = "regional"

  tags = {
    Name = "${var.swan_eks_cluster_name}-swan_rnat"
  }
}

resource "aws_route_table" "swan_private_route_table" {
  vpc_id = aws_vpc.swan_vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.swan_rnat.id
  }

  tags = {
    Name = "${var.swan_eks_cluster_name}-swan_private_route_table"
  }
}

resource "aws_route_table_association" "swan_private_route_table_association" {
  count          = length(var.swan_private_subnet_cidr_blocks)
  subnet_id      = aws_subnet.swan_private_subnets[count.index].id
  route_table_id = aws_route_table.swan_private_route_table.id
}