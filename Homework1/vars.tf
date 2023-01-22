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

#variable "tags" {
#  type = list({
#   owner = "Grandpa"
#    server_name = "nginx${count.index}"
#    purpose = "Whiskey_web"
#  })
  
#}