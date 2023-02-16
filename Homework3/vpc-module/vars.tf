variable "public_subnet_cidrs" {
 type        = list(string)
 description = "Public Subnet CIDR values"
}
 
variable "private_subnet_cidrs" {
 type        = list(string)
 description = "Private Subnet CIDR values"
}

variable "vpc_cidr" {
  type = string
  description = "The cidr block of the VPC"
}

variable "route_tables_name_list" {
  type    = list(string)
  description = "List of the names of the route-tables (Module creates two RTBS, one public [0] and one private [1]"
  default = ["public", "private-a", "private-b"]
}