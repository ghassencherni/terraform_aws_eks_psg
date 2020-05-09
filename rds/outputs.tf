#----rds/outputs.tf----

output "wordpress_db_endpoint" {
  value = "${aws_db_instance.wordpress_db.endpoint}"
}
