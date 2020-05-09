#----root/variables.tf----

variable "aws_region" {}

variable "vpc_cidr" {}

variable "public_cidr_subnet" {
  type = "list"
}

variable "private_cidr_subnet" {
  type = "list"
}

variable "identifier" {}

variable "dbname" {}

variable "dbuser" {}

variable "dbpassword" {}

variable "db_instance_class" {}
