###
# subnet
###
# lb
variable "lb_subnet_cidr_block" {
  default = "10.0.0.0/26"
}
# admin
variable "admin_subnet_cidr_block" {
  default = "10.0.10.0/26"
}
# web
variable "web_subnet_cidr_block" {
  default = "10.0.20.0/26"
}
# db
variable "db_subnet_cidr_block" {
  default = "10.0.30.0/26"
}


# public_ip
variable "public_ip_on_vnic" {
  default = "false"
}
# private_ip
variable "private_ip_on_vnic" {
  default = "true"
}