#----root/main.tf----

provider "aws" {
  region = "${var.aws_region}"
}

# Deploy Networking: VPC, Subnets, Internet gateway,...
module "networking" {
  source              = "./networking"
  aws_region          = "${var.aws_region}"
  vpc_cidr            = "${var.vpc_cidr}"
  public_cidr_subnet  = "${var.public_cidr_subnet}"
  private_cidr_subnet = "${var.private_cidr_subnet}"
}

# Deploy Security Groups
module "security" {
  source              = "./security"
  aws_region          = "${var.aws_region}"
  wordpress_vpc_id    = "${module.networking.wordpress_vpc_id}"
  public_cidr_subnet  = "${var.public_cidr_subnet}"
  private_cidr_subnet = "${var.private_cidr_subnet}"
}

# Deploy the RDS instance used for our wordpress
module "rds" {
  source            = "./rds"
  aws_region        = "${var.aws_region}"
  db_instance_class = "${var.db_instance_class}"
  identifier        = "${var.dbname}"
  dbname            = "${var.dbname}"
  dbuser            = "${var.dbuser}"
  dbpassword        = "${var.dbpassword}"

  #wordpress_private_subnet_id           = "${module.networking.wordpress_private_subnet_id}"
  wordpress_private_sg_id        = "${module.security.wordpress_private_sg_id}"
  wordpress_private_sg_name      = "${module.security.wordpress_private_sg_name}"
  wordpress_db_subnet_group_name = "${module.networking.wordpress_db_subnet_group_name}"
}

# Deploy the EKS cluster for our wordpress 
module "eks-artifakt" {
  source                       = "./eks-artifakt"
  aws_region                   = "${var.aws_region}"
  wordpress_public_subnets_ids = "${module.networking.wordpress_public_subnets_ids}"
  wordpress_public_sg_id       = "${module.security.wordpress_public_sg_id}"
}
