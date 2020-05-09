#----eks-artifakt/main.tf----
#
# EKS Cluster Resources
#  * IAM Role to allow EKS service to manage other AWS services
#  * EKS Cluster and Node group
#

# POLICIES
# Create the IAM role for our Artifakt Cluster
resource "aws_iam_role" "artifakt-cluster" {
  name = "artifakt-cluster-role"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "eks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

# Create the IAM role for our worker nodes
resource "aws_iam_role" "artifakt-nodes" {
  name = "artifakt-nodes-role"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

# ATTACH POLICIES TO CLUSTER AND WORKER NODES IAM ROLES
# Attach the EKS Cluster Policy to our Cluster IAM role
resource "aws_iam_role_policy_attachment" "artifakt-cluster-AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = "${aws_iam_role.artifakt-cluster.name}"
}

# Attach the EKS Service Policy to our Cluster IAM role
resource "aws_iam_role_policy_attachment" "artifakt-cluster-AmazonEKSServicePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
  role       = "${aws_iam_role.artifakt-cluster.name}"
}

# Attach the EKS Worker Policy to our worker nodes IAM role
resource "aws_iam_role_policy_attachment" "artifakt-nodes-AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = "${aws_iam_role.artifakt-nodes.name}"
}

# Attach the EKS CNI Policy to our worker nodes IAM role
resource "aws_iam_role_policy_attachment" "artifakt-nodes-AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = "${aws_iam_role.artifakt-nodes.name}"
}

# Attach the EC2 Container Registry ReadOnly Policy to our worker nodes IAM role
# Will not be used, in our case we will use gitlab registry ( artifakt spec )
resource "aws_iam_role_policy_attachment" "artifakt-nodes-AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = "${aws_iam_role.artifakt-nodes.name}"
}

# BUILDING EKS 
# Create the EKS Cluster
resource "aws_eks_cluster" "artifakt-cluster" {
  name     = "artifakt-cluster"
  role_arn = "${aws_iam_role.artifakt-cluster.arn}"

  vpc_config {
    security_group_ids = ["${var.wordpress_public_sg_id}"]
    subnet_ids         = ["${var.wordpress_public_subnets_ids}"]
  }

  depends_on = [
    "aws_iam_role_policy_attachment.artifakt-cluster-AmazonEKSClusterPolicy",
    "aws_iam_role_policy_attachment.artifakt-cluster-AmazonEKSServicePolicy",
  ]
}

# Create the Node Group 
resource "aws_eks_node_group" "artifakt-nodes" {
  cluster_name    = "${aws_eks_cluster.artifakt-cluster.name}"
  node_group_name = "mynodegroup"
  node_role_arn   = "${aws_iam_role.artifakt-nodes.arn}"
  subnet_ids      = ["${var.wordpress_public_subnets_ids}"]

  scaling_config {
    desired_size = 2
    max_size     = 3
    min_size     = 1
  }

  depends_on = [
    "aws_iam_role_policy_attachment.artifakt-nodes-AmazonEKSWorkerNodePolicy",
    "aws_iam_role_policy_attachment.artifakt-nodes-AmazonEKS_CNI_Policy",
    "aws_iam_role_policy_attachment.artifakt-nodes-AmazonEC2ContainerRegistryReadOnly",
  ]
}
