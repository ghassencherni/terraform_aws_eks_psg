#----networking/variables.tf----

variable "aws_region" {}

variable "vpc_cidr" {}

variable "public_cidr_subnet" {
  type = "list"
}

variable "private_cidr_subnet" {
  type = "list"
}
