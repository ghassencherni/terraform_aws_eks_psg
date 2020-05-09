#----networking/main.tf----

# Allows access to the list of AWS Availability within the region configured in the provider
data "aws_availability_zones" "available" {}

# Creation of the Custom VPC
resource "aws_vpc" "wordpress_vpc" {
  cidr_block           = "${var.vpc_cidr}"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags {
    Name = "wordpress_vpc"
  }
}

# Creation of Internet gateway and attach it to our new VPC
resource "aws_internet_gateway" "wordpress_netgate" {
  vpc_id = "${aws_vpc.wordpress_vpc.id}"

  tags {
    Name = "wordpress_netgate"
  }
}

# Creation  of the public route table ( associated with the internet gateway ) and defining the route to the internet
resource "aws_route_table" "wordpress_pub_rt" {
  vpc_id = "${aws_vpc.wordpress_vpc.id}"

  route = {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.wordpress_netgate.id}"
  }

  tags {
    Name = "wordpress_pub_rt"
  }
}

# Creation of the private route table ( the main route table, aws recomendation ) 
resource "aws_default_route_table" "wordpress_priv_rt" {
  default_route_table_id = "${aws_vpc.wordpress_vpc.default_route_table_id}"

  tags {
    Name = "wordpress_priv_rt"
  }
}

# Creation of the public subnest reserved for our EKS: at least EKS needs two subnets
resource "aws_subnet" "wordpress_public_subnet" {
  count                   = 2
  vpc_id                  = "${aws_vpc.wordpress_vpc.id}"
  cidr_block              = "${var.public_cidr_subnet[count.index]}"
  map_public_ip_on_launch = true
  availability_zone       = "${data.aws_availability_zones.available.names[count.index]}"

  tags {
    Name = "wordpress_public_subnet_${count.index + 1}"
    "kubernetes.io/role/elb" = "1"
    "KubernetesCluster" = "artifakt-cluster"
  }
}

# Associate our public subnets to the public route table 
resource "aws_route_table_association" "public_rt_assoc" {
  count          = 2
  subnet_id      = "${aws_subnet.wordpress_public_subnet.*.id[count.index]}"
  route_table_id = "${aws_route_table.wordpress_pub_rt.id}"
}

# Creation of the private subnet reserved for our RDS ( wordpress database )
# Insted of using mysql POD managed by the kubernetes cluster
resource "aws_subnet" "wordpress_private_subnet" {
  count      = 2
  vpc_id     = "${aws_vpc.wordpress_vpc.id}"
  cidr_block = "${var.private_cidr_subnet[count.index]}"

  # it's mandatory to split subnets between multiple AZ in order to create a DB subnet group 
  availability_zone = "${data.aws_availability_zones.available.names[count.index]}"

  tags {
    Name = "wordpress_private_subnet_${count.index + 1}"
  }
}

# Associate our private subnets to the private route table
resource "aws_route_table_association" "private_rt_assoc" {
  count          = 2
  subnet_id      = "${aws_subnet.wordpress_private_subnet.*.id[count.index]}"
  route_table_id = "${aws_default_route_table.wordpress_priv_rt.id}"
}

# Creation of the RDS Subnet Group
resource "aws_db_subnet_group" "wordpress_db_subnet_group" {
  name       = "wordpress_db_subnet_group"
  subnet_ids = ["${aws_subnet.wordpress_private_subnet.*.id}"]
}
