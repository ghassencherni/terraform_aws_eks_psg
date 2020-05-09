#----networking/variables.tf----

variable "aws_region" {}

variable "wordpress_vpc_id" {}

variable "public_cidr_subnet" {
  type = "list"
}

variable "private_cidr_subnet" {}
