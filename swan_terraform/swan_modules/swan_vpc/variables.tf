variable "swan_vpc_cidr_block" {
  type = string
}

variable "swan_private_subnet_cidr_blocks" {
  type = list(string)
}

variable "swan_availability_zones" {
  type = list(string)
}

variable "swan_private_subnet_tags" {
  type    = map(string)
  default = {}
}

variable "swan_name_prefix" {
  type = string
}