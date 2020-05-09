#----security/output.tf----

output "wordpress_public_sg_id" {
  value = "${aws_security_group.wordpress_public_sg.id}"
}

output "wordpress_private_sg_id" {
  value = "${aws_security_group.wordpress_private_sg.id}"
}

output "wordpress_private_sg_name" {
  value = "${aws_security_group.wordpress_private_sg.name}"
}

output "aws_iam_server_certificate_id" {
  value = "${aws_iam_server_certificate.artifakt_server_cert.arn}"
}

