#----eks-artifakt/variables.tf----

variable "aws_region" {}

variable "wordpress_public_subnets_ids" {
  type = "list"
}

variable "wordpress_public_sg_id" {}

#variable "kubeconfigpath" {}
#  default = "/root/.kube/config"
#}

