# terraform_aws_eks
Pipeline (Jenkinsfile) to deploy AWS resources on AWS, it comes with other projects : [deploy_jenkins](https://github.com/ghassencherni/deploy_jenkins), [wordpress_k8s](https://github.com/ghassencherni/wordpress_k8s) and [wp_custom_docker](https://github.com/ghassencherni/wp_custom_docker).

Please start loocking in [deploy_jenkins](https://github.com/ghassencherni/deploy_jenkins) First.


## Getting Started

This Jenkinsfile allows to build the needed resources on AWS in order to run wordpress ( from a customized image ) on EKS:

It calls terraform to deploy 3 modules :

- Newtorking module: 

-- Create VPC

-- Create the internet Gateway

-- Create 1 public route table 

-- Create private route table

-- Create 2 public subnets for EKS Nodes

-- Create 2 private sunets for RDS ( able to run RDS cluster : not the case of this project ) 

-- Create 1 RDS Subnet Group 

-- Create 2 route tables  association ( for public and private route table )


- Security module:
 
-- Create public security group ( ingress : 443 )

-- Create private security group ( ingreee : 3306 from public cidr subnets ) => allows connection from PODS to RDS 


- Eks-artifakt module:

-- Create IAM Roles : allows EKS service to manage other AWS services ( for cluster and for the worker nodes ) 

-- Create EKS

-- Create the Node group


- RDS module: 

-- Create the RDS instance ( used as wordpress DB for the cluster )


 
## Requirements

- AWS access key ID and Secret key access must be stored on Jenkins ( Global credential ) with the id "aws_credentials"

- Gitlab account ( user and password ) must be stored on Jenkins ( Global credential ) with the id "gitlab_registry"


## Variables

- AWS region where to build the VPC and all ressources inside

    aws_region = "eu-west-3"


- The VPC CIDR

    vpc_cidr = "10.0.0.0/16"


- The CIDR of the two public subnets

    public_cidr_subnet = [
      "10.0.1.0/24",
      "10.0.2.0/24"
    ]


- The CIDR of the two private subnets

    private_cidr_subnet = [
      "10.0.3.0/24",
      "10.0.4.0/24"
    ]


- The AWS RDS name

    identifier = "wordpressdb"


- The dabase name ( default wordpressdb ) 

dbname = "wordpressdb"


- The database user 

    dbuser = "wordpressuser"


- The database password 

    dbpassword = "mypassword"


- The database instance class 

    db_instance_class = "db.t2.small"


## Author Information

This script  was created by [Ghassen CHARNI](https://github.com/ghassencherni/)
