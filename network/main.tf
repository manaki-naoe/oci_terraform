###############
# resource
###############
# VCN
resource "oci_core_vcn" "my_vcn" {
  cidr_block     = "${var.vcn_cidr_block}"
  compartment_id = "${var.compartment_ocid}"
  display_name   = "${var.sysname}-${var.env}-vcn"
  dns_label      = "${var.sysname}vcn"
}

# Internet Gateway
resource "oci_core_internet_gateway" "internet_gateway" {
  compartment_id = "${var.compartment_ocid}"
  vcn_id         = "${oci_core_vcn.my_vcn.id}"
  display_name   = "${var.sysname}-${var.env}-igw"
  enabled        = true
}

# Nat Gateway
resource "oci_core_nat_gateway" "nat_gateway" {
  compartment_id = "${var.compartment_ocid}"
  vcn_id         = "${oci_core_vcn.my_vcn.id}"
  display_name   = "${var.sysname}-${var.env}-ngw"
}

###
# route table
###
# public route table
resource "oci_core_route_table" "public_route_table" {
  compartment_id = "${var.compartment_ocid}"
  route_rules {
    network_entity_id = "${oci_core_internet_gateway.internet_gateway.id}"
    destination       = "0.0.0.0/0"
  }
  vcn_id       = "${oci_core_vcn.my_vcn.id}"
  display_name   = "${var.sysname}-${var.env}-public-rtb"
}

# private route table
resource "oci_core_route_table" "private_route_table" {
  compartment_id = "${var.compartment_ocid}"
  route_rules {
    network_entity_id = "${oci_core_nat_gateway.nat_gateway.id}"
    destination       = "0.0.0.0/0"
  }
  vcn_id       = "${oci_core_vcn.my_vcn.id}"
  display_name   = "${var.sysname}-${var.env}-private-rtb"
}

###
# Security Groups
###
# default
resource "oci_core_network_security_group" "default_network_security_group" {
  compartment_id = "${var.compartment_ocid}"
  vcn_id         = "${oci_core_vcn.my_vcn.id}"
  display_name   = "${var.sysname}-${var.env}-default-sg"
}

# admin
resource "oci_core_network_security_group" "admin_network_security_group" {
  compartment_id = "${var.compartment_ocid}"
  vcn_id         = "${oci_core_vcn.my_vcn.id}"
  display_name   = "${var.sysname}-${var.env}-admin-sg"
}

# web
resource "oci_core_network_security_group" "web_network_security_group" {
  compartment_id = "${var.compartment_ocid}"
  vcn_id         = "${oci_core_vcn.my_vcn.id}"
  display_name   = "${var.sysname}-${var.env}-web-sg"
}

# db
resource "oci_core_network_security_group" "db_network_security_group" {
  compartment_id = "${var.compartment_ocid}"
  vcn_id         = "${oci_core_vcn.my_vcn.id}"
  display_name   = "${var.sysname}-${var.env}-db-sg"
}

# lb
resource "oci_core_network_security_group" "lb_network_security_group" {
  compartment_id = "${var.compartment_ocid}"
  vcn_id         = "${oci_core_vcn.my_vcn.id}"
  display_name   = "${var.sysname}-${var.env}-lb-sg"
}

###
# Security Rules for Security Groups
###
# specific_ip_ssh
resource "oci_core_network_security_group_security_rule" "default_network_security_group_security_rule" {
  network_security_group_id = "${oci_core_network_security_group.admin_network_security_group.id}"
  direction                 = "${var.sg_direction_ingress}"
  protocol                  = "${var.sg_protocol_tcp}"
  description               = "${var.sg_description_specific_ip_ssh}"
  source                    = "${var.sg_source_specific_ip}"
  source_type               = "${var.sg_source_type_cidr}"
  tcp_options {
    destination_port_range {
      max = "${var.sg_destination_port_range_max_ssh}"
      min = "${var.sg_destination_port_range_min_ssh}"
    }
  }
}

# http to admin
resource "oci_core_network_security_group_security_rule" "http_admin_network_security_group_security_rule" {
  network_security_group_id = "${oci_core_network_security_group.admin_network_security_group.id}"
  direction                 = "${var.sg_direction_ingress}"
  protocol                  = "${var.sg_protocol_tcp}"
  description               = "${var.sg_description_all_http}"
  source                    = "${var.sg_source_all}"
  source_type               = "${var.sg_source_type_cidr}"
  tcp_options {
    destination_port_range {
      max = "${var.sg_destination_port_range_max_http}"
      min = "${var.sg_destination_port_range_min_http}"
    }
  }
}

# web-sg to admin
resource "oci_core_network_security_group_security_rule" "web-ngs_admin_network_security_group_security_rule" {
  network_security_group_id = "${oci_core_network_security_group.admin_network_security_group.id}"
  direction                 = "${var.sg_direction_ingress}"
  protocol                  = "${var.sg_protocol_all}"
  description               = "${var.sg_description_web_access}"
  source                    = "${oci_core_network_security_group.web_network_security_group.id}"
  source_type               = "${var.sg_source_type_nsg}"
}

# db-sg to admin
resource "oci_core_network_security_group_security_rule" "db-ngs_admin_network_security_group_security_rule" {
  network_security_group_id = "${oci_core_network_security_group.admin_network_security_group.id}"
  direction                 = "${var.sg_direction_ingress}"
  protocol                  = "${var.sg_protocol_all}"
  description               = "${var.sg_description_db_access}"
  source                    = "${oci_core_network_security_group.db_network_security_group.id}"
  source_type               = "${var.sg_source_type_nsg}"
}

# lb-sg http to web
resource "oci_core_network_security_group_security_rule" "lb-http_web_network_security_group_security_rule" {
  network_security_group_id = "${oci_core_network_security_group.web_network_security_group.id}"
  direction                 = "${var.sg_direction_ingress}"
  protocol                  = "${var.sg_protocol_tcp}"
  description               = "${var.sg_description_lb_http}"
  source                    = "${oci_core_network_security_group.lb_network_security_group.id}"
  source_type               = "${var.sg_source_type_nsg}"
  tcp_options {
    destination_port_range {
      max = "${var.sg_destination_port_range_max_http}"
      min = "${var.sg_destination_port_range_min_http}"
    }
  }
}

# lb-sg https to web
resource "oci_core_network_security_group_security_rule" "lb-https_web_network_security_group_security_rule" {
  network_security_group_id = "${oci_core_network_security_group.web_network_security_group.id}"
  direction                 = "${var.sg_direction_ingress}"
  protocol                  = "${var.sg_protocol_tcp}"
  description               = "${var.sg_description_lb_https}"
  source                    = "${oci_core_network_security_group.lb_network_security_group.id}"
  source_type               = "${var.sg_source_type_nsg}"
  tcp_options {
    destination_port_range {
      max = "${var.sg_destination_port_range_max_https}"
      min = "${var.sg_destination_port_range_min_https}"
    }
  }
}

# admin-sg to web
resource "oci_core_network_security_group_security_rule" "admin-ngs_web_network_security_group_security_rule" {
  network_security_group_id = "${oci_core_network_security_group.web_network_security_group.id}"
  direction                 = "${var.sg_direction_ingress}"
  protocol                  = "${var.sg_protocol_all}"
  description               = "${var.sg_description_admin_access}"
  source                    = "${oci_core_network_security_group.admin_network_security_group.id}"
  source_type               = "${var.sg_source_type_nsg}"
}

# db-sg to web
resource "oci_core_network_security_group_security_rule" "db-ngs_web_network_security_group_security_rule" {
  network_security_group_id = "${oci_core_network_security_group.web_network_security_group.id}"
  direction                 = "${var.sg_direction_ingress}"
  protocol                  = "${var.sg_protocol_all}"
  description               = "${var.sg_description_db_access}"
  source                    = "${oci_core_network_security_group.db_network_security_group.id}"
  source_type               = "${var.sg_source_type_nsg}"
}

# web-sg to web
resource "oci_core_network_security_group_security_rule" "web-ngs_web_network_security_group_security_rule" {
  network_security_group_id = "${oci_core_network_security_group.web_network_security_group.id}"
  direction                 = "${var.sg_direction_ingress}"
  protocol                  = "${var.sg_protocol_all}"
  description               = "${var.sg_description_web_access}"
  source                    = "${oci_core_network_security_group.web_network_security_group.id}"
  source_type               = "${var.sg_source_type_nsg}"
}

# admin-sg to db
resource "oci_core_network_security_group_security_rule" "admin-ngs_db_network_security_group_security_rule" {
  network_security_group_id = "${oci_core_network_security_group.db_network_security_group.id}"
  direction                 = "${var.sg_direction_ingress}"
  protocol                  = "${var.sg_protocol_all}"
  description               = "${var.sg_description_admin_access}"
  source                    = "${oci_core_network_security_group.admin_network_security_group.id}"
  source_type               = "${var.sg_source_type_nsg}"
}

# web-sg to db
resource "oci_core_network_security_group_security_rule" "web-ngs_db_network_security_group_security_rule" {
  network_security_group_id = "${oci_core_network_security_group.db_network_security_group.id}"
  direction                 = "${var.sg_direction_ingress}"
  protocol                  = "${var.sg_protocol_all}"
  description               = "${var.sg_description_web_access}"
  source                    = "${oci_core_network_security_group.web_network_security_group.id}"
  source_type               = "${var.sg_source_type_nsg}"
}

# db-sg to db
resource "oci_core_network_security_group_security_rule" "db-ngs_db_network_security_group_security_rule" {
  network_security_group_id = "${oci_core_network_security_group.db_network_security_group.id}"
  direction                 = "${var.sg_direction_ingress}"
  protocol                  = "${var.sg_protocol_all}"
  description               = "${var.sg_description_db_access}"
  source                    = "${oci_core_network_security_group.db_network_security_group.id}"
  source_type               = "${var.sg_source_type_nsg}"
}

# http to lb
resource "oci_core_network_security_group_security_rule" "http_publb_network_security_group_security_rule" {
  network_security_group_id = "${oci_core_network_security_group.lb_network_security_group.id}"
  direction                 = "${var.sg_direction_ingress}"
  protocol                  = "${var.sg_protocol_tcp}"
  description               = "${var.sg_description_http}"
  source                    = "${var.sg_source_all}"
  source_type               = "${var.sg_source_type_cidr}"
  tcp_options {
    destination_port_range {
      max = "${var.sg_destination_port_range_max_http}"
      min = "${var.sg_destination_port_range_min_http}"
    }
  }
}

# https to lb
resource "oci_core_network_security_group_security_rule" "https_publb_network_security_group_security_rule" {
  network_security_group_id = "${oci_core_network_security_group.lb_network_security_group.id}"
  direction                 = "${var.sg_direction_ingress}"
  protocol                  = "${var.sg_protocol_tcp}"
  description               = "${var.sg_description_https}"
  source                    = "${var.sg_source_all}"
  source_type               = "${var.sg_source_type_cidr}"
  tcp_options {
    destination_port_range {
      max = "${var.sg_destination_port_range_max_https}"
      min = "${var.sg_destination_port_range_min_https}"
    }
  }
}


###
# Subents
###
# lb
resource "oci_core_subnet" "lb_subnet" {
  availability_domain = "${var.availability_domain}"
  cidr_block          = "${var.lb_subnet_cidr_block}"
  compartment_id      = "${var.compartment_ocid}"
  vcn_id              = "${oci_core_vcn.my_vcn.id}"

  display_name               = "${var.sysname}-${var.env}-lb-public-subnet"
  dns_label                  = "${var.env}lbsubnet"
  prohibit_public_ip_on_vnic = "${var.public_ip_on_vnic}"
  route_table_id             = "${oci_core_route_table.public_route_table.id}"
}

# Subent(admin)
resource "oci_core_subnet" "admin_subnet" {
  availability_domain = "${var.availability_domain}"
  cidr_block          = "${var.admin_subnet_cidr_block}"
  compartment_id      = "${var.compartment_ocid}"
  vcn_id              = "${oci_core_vcn.my_vcn.id}"

  display_name               = "${var.sysname}-${var.env}-admin-public-subnet"
  dns_label                  = "${var.env}adminsubnet"
  prohibit_public_ip_on_vnic = "${var.public_ip_on_vnic}"
  route_table_id             = "${oci_core_route_table.public_route_table.id}"
}

# Subent(Web)
resource "oci_core_subnet" "web_subnet" {
  availability_domain = "${var.availability_domain}"
  cidr_block          = "${var.web_subnet_cidr_block}"
  compartment_id      = "${var.compartment_ocid}"
  vcn_id              = "${oci_core_vcn.my_vcn.id}"

  display_name               = "${var.sysname}-${var.env}-web-private-subnet"
  dns_label                  = "${var.env}websubnet"
  prohibit_public_ip_on_vnic = "${var.private_ip_on_vnic}"
  route_table_id             = "${oci_core_route_table.private_route_table.id}"
}

# Subent(db)
resource "oci_core_subnet" "db_subnet" {
  availability_domain = "${var.availability_domain}"
  cidr_block          = "${var.db_subnet_cidr_block}"
  compartment_id      = "${var.compartment_ocid}"
  vcn_id              = "${oci_core_vcn.my_vcn.id}"

  display_name               = "${var.sysname}-${var.env}-db-private-subnet"
  dns_label                  = "${var.env}dbsubnet"
  prohibit_public_ip_on_vnic = "${var.private_ip_on_vnic}"
  route_table_id             = "${oci_core_route_table.private_route_table.id}"
}