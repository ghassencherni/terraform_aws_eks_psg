#----root/outputs.tf----
resource "local_file" "kubeconfig" {
  content = <<KUBECONFIG
apiVersion: v1
clusters:
- cluster:
    server: ${module.eks-artifakt.cluster-endpoint}
    certificate-authority-data: ${module.eks-artifakt.cert-auth}
  name: kubernetes
contexts:
- context:
    cluster: kubernetes
    user: aws
  name: aws
current-context: aws
kind: Config
preferences: {}
users:
- name: aws
  user:
    exec:
      apiVersion: client.authentication.k8s.io/v1alpha1
      command: aws-iam-authenticator
      args:
        - "token"
        - "-i"
        - "artifakt-cluster"
KUBECONFIG

  filename = "config"
}


resource "local_file" "rds_conn_configmap" {
  content = <<RDSCONN
apiVersion: v1
kind: ConfigMap
metadata:
  name: rds-conn
  namespace: default
data:

  DB_HOST: "${module.rds.wordpress_db_endpoint}"
  DB_PASSWORD: "${var.dbpassword}"
  DB_USERNAME: "${var.dbuser}"


RDSCONN

  filename = "rds_conn_configmap.yaml"
}

resource "local_file" "service_wordpress" {
  content = <<SERVICE
---
apiVersion: v1
kind: Service
metadata:
  name: wordpress-service
  annotations:
    # Note that the backend talks over HTTP.
    service.beta.kubernetes.io/aws-load-balancer-backend-protocol: http
    # The ARN of the certificate.
    service.beta.kubernetes.io/aws-load-balancer-ssl-cert: "${module.security.aws_iam_server_certificate_id}"
    # Only run SSL on the port named "https" below.
    service.beta.kubernetes.io/aws-load-balancer-ssl-ports: "https"
spec:
  type: LoadBalancer
  selector:
    app: wordpress
  ports:
  - name: http
    port: 80
    targetPort: 80
  - name: https
    port: 443
    targetPort: 80

SERVICE

  filename= "service_wordpress.yaml"
}
