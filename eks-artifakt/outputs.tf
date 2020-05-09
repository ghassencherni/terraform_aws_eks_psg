#----eks-artifakt/outputs.tf----

output "cluster-endpoint" {
  value = "${aws_eks_cluster.artifakt-cluster.endpoint}"
}

output "cert-auth" {
  value = "${aws_eks_cluster.artifakt-cluster.certificate_authority.0.data}"
}
