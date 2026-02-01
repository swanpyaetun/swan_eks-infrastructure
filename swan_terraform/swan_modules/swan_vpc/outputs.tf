output "swan_vpc_id" {
  value = aws_vpc.swan_vpc.id
}

output "swan_private_subnet_ids" {
  value = aws_subnet.swan_private_subnets[*].id
}