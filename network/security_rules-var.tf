###
# common
###
variable "sg_direction_ingress" {
  default = "INGRESS"
}
variable "sg_protocol_tcp" {
  default = "6"
}
variable "sg_protocol_all" {
  default = "ALL"
}
variable "sg_source_all" {
  default = "0.0.0.0/0"
}
variable "sg_source_specific_ip" {
  default = "0.0.0.0/0"
}
variable "sg_source_type_cidr" {
  default = "CIDR_BLOCK"
}
variable "sg_source_type_nsg" {
  default = "NETWORK_SECURITY_GROUP"
}
variable "sg_destination_port_range_max_ssh" {
  default = "22"
}
variable "sg_destination_port_range_min_ssh" {
  default = "22"
}
variable "sg_destination_port_range_max_http" {
  default = "80"
}
variable "sg_destination_port_range_min_http" {
  default = "80"
}
variable "sg_destination_port_range_max_https" {
  default = "443"
}
variable "sg_destination_port_range_min_https" {
  default = "443"
}

###
# description
###
variable "sg_description_specific_ip_ssh" {
  default = "指定IPからのSSH"
}
variable "sg_description_all_ssh" {
  default = "全てのIPからのSSH"
}
variable "sg_description_all_http" {
  default = "全てのIPからのHTTPアクセス"
}
variable "sg_description_all_https" {
  default = "全てのIPからのHTTPSアクセス"
}
variable "sg_description_admin_access" {
  default = "admin-sgからのアクセス"
}
variable "sg_description_web_access" {
  default = "web-sgからのアクセス"
}
variable "sg_description_db_access" {
  default = "db-sgからのアクセス"
}
variable "sg_description_lb_http" {
  default = "lb-sgからのHTTPアクセス"
}
variable "sg_description_lb_https" {
  default = "lb-sgからのHTTPSアクセス"
}
variable "sg_description_http" {
  default = "80番へのアクセス"
}
variable "sg_description_https" {
  default = "443番へのアクセス"
}