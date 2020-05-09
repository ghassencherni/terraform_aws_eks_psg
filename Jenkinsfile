node {
  
  /* Cloning our repo in the workspace */
  git 'https://github.com/ghassencherni/terraform_aws_eks_psg.git'

  if(action == 'Deploy') {
    stage('init') {
        sh """
            terraform init
        """
    }
    stage('plan') {
    withCredentials([usernamePassword(credentialsId: 'aws_credentials', usernameVariable: 'ACCESS_KEY', passwordVariable: 'SECRET_ACCESS')]) {
    /* Let's check the terraform plan and what aws resources will be added or modified */
      sh label: 'terraform plan', script: "export AWS_ACCESS_KEY_ID='$ACCESS_KEY';export AWS_SECRET_ACCESS_KEY='$SECRET_ACCESS';terraform plan -out=tfplan -input=false -var aws_region=${aws_region} -var vpc_cidr=${vpc_cidr} '-var=public_cidr_subnet=[\"${public_cidr_subnet_1}\",\"${public_cidr_subnet_2}\"]' '-var=private_cidr_subnet=[\"${private_cidr_subnet_1}\",\"${private_cidr_subnet_2}\"]' -var identifier=${identifier} -var dbname=${dbname} -var dbuser=${dbuser} -var dbpassword=${dbpassword}"
      script {
          timeout(time: 10, unit: 'MINUTES') {
              input(id: "Deploy Gate", message: "Deploy environment?", ok: 'Deploy')
          }
        }
      }
    }
    stage('apply') {
    withCredentials([usernamePassword(credentialsId: 'aws_credentials', usernameVariable: 'ACCESS_KEY', passwordVariable: 'SECRET_ACCESS')])     {

    /* Apply the change on AWS */
        sh label: 'terraform apply', script: "export AWS_ACCESS_KEY_ID='$ACCESS_KEY';export AWS_SECRET_ACCESS_KEY='$SECRET_ACCESS';terraform apply -lock=false -input=false tfplan"

        /* "rds_conn_configmap.yaml" and "config" files are needed to deploy the wordpress EKS cluster, we will used it as artifacts */
        archiveArtifacts artifacts: 'service_wordpress.yaml, rds_conn_configmap.yaml, config'

    }
  }
}
    if(action == 'Destroy') {
    stage('plan_destroy') {
    withCredentials([usernamePassword(credentialsId: 'aws_credentials', usernameVariable: 'ACCESS_KEY', passwordVariable: 'SECRET_ACCESS')])     {
      /* This shows what resources will be destoryed */
      sh label: 'terraform plan destroy', script: "export AWS_ACCESS_KEY_ID='$ACCESS_KEY';export AWS_SECRET_ACCESS_KEY='$SECRET_ACCESS';terraform plan -destroy -out=tfdestroyplan -input=false -var aws_region=${aws_region} -var vpc_cidr=${vpc_cidr} '-var=public_cidr_subnet=[\"${public_cidr_subnet_1}\",\"${public_cidr_subnet_2}\"]' '-var=private_cidr_subnet=[\"${private_cidr_subnet_1}\",\"${private_cidr_subnet_2}\"]' -var identifier=${identifier} -var dbname=${dbname} -var dbuser=${dbuser} -var dbpassword=${dbpassword}"
    } 
   }
    stage('destroy') {
      script {
          timeout(time: 10, unit: 'MINUTES') {
              input(id: "Destroy Gate", message: "Destroy environment?", ok: 'Destroy')
          }
      }
    withCredentials([usernamePassword(credentialsId: 'aws_credentials', usernameVariable: 'ACCESS_KEY', passwordVariable: 'SECRET_ACCESS')])
    {
      /* Trigger wordpress_k8s job in order to destroy the wordpress cluster */
      build job: 'wordpress_k8s', parameters: [string(name: 'Action', value: 'Destroy Wordpress')], quietPeriod: 5 
      sh label: 'Destroy environment', script: "export AWS_ACCESS_KEY_ID='$ACCESS_KEY';export AWS_SECRET_ACCESS_KEY='$SECRET_ACCESS';terraform apply -lock=false -input=false tfdestroyplan" 
    }
   }
  }
}

