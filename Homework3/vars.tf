variable "region" {
  type = string
  default = "us-east-1"
}

variable "key_name" {
  type = string
  default = "nginx_web"
  description = "The key name of the Key Pair to use for the instance"
}  

variable "private_key_path" {
  type = string
  default = "~/.ssh/id_rsa-terraform"
} 

variable "owner_tag" {
  description = "The owner tag will be applied to every resource in the project through the 'default variables' feature"
  default     = "Ops-School"
  type        = string
}

variable "purpose_tag" {
  default = "Whiskey"
  type    = string
}

variable "DB_instances_count" {
  description = "The number of DB instances to create"
  default     = 2
}

variable "nginx_instances_count" {
  description = "The number of Nginx instances to create"
  default     = 2
}

variable "instance_type" {
  description = "The type of the ec2, for example - t2.medium"
  default     = "t2.micro"
  type        = string
}

variable "nginx_root_disk_size" {
  description = "The size of the root disk"
  default     = 10
}

variable "nginx_encrypted_disk_size" {
  description = "The size of the secondary encrypted disk"
  default     = 10
}

variable "nginx_encrypted_disk_device_name" {
  description = "The name of the device of secondary encrypted disk"
  default     = "xvdh"
  type        = string
}

variable "volumes_type" {
  description = "The type of all the disk instances in my project"
  default     = "gp2"
}