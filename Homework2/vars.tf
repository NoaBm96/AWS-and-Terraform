variable "key_name" {
  type = string
  default = "nginx_web"
}    
variable "private_key_path" {
  type = string
  default = "~/.ssh/id_rsa-terraform"
} 

variable "region" {
  type = string
  default = "us-east-1"
}

variable "public_subnet_cidrs" {
 type        = list(string)
 description = "Public Subnet CIDR values"
 default     = ["10.0.1.0/24", "10.0.2.0/24"]
}
 
variable "private_subnet_cidrs" {
 type        = list(string)
 description = "Private Subnet CIDR values"
 default     = ["10.0.3.0/24", "10.0.4.0/24"]
}

variable "vpc_cidr" {
  type = string
  default = "10.0.0.0/16"
}
