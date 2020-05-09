#-----networking/outputs.tf----

output "wordpress_vpc_id" {
  value = "${aws_vpc.wordpress_vpc.id}"
}

output "wordpress_public_subnets_ids" {
  value = "${aws_subnet.wordpress_public_subnet.*.id}"
}

output "wordpress_private_subnet_id" {
  value = "${aws_subnet.wordpress_private_subnet.*.id}"
}

output "wordpress_db_subnet_group_name" {
  value = "${aws_db_subnet_group.wordpress_db_subnet_group.name}"
}
