output "swan_private_subnet_ids" {
  value = aws_subnet.swan_private_subnets[*].id
}