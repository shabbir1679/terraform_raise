# see inputs.tf for configurable variables


# output parameter with the cluster's endpoint
resource "aws_ssm_parameter" "eksendpoint" {
  count = "${var.ekscluster}"
  name  = "/${var.prefix}/${var.envname}/${var.appname}/eks/endpoint"
  type  = "String"
  value = "${aws_eks_cluster.app.endpoint}"
  overwrite = "true"
}


/*
resource "aws_security_group" "eks-control-plane-sg" {
  // count = "${var.ekscluster}"
  name        = "${var.prefix}-${var.appname}-${var.envname}-control-plane"
  vpc_id      = "${var.vpc}"
  tags        = "${merge(var.tags, map("Name", "${var.prefix}-${var.appname}-${var.envname}-eks-control-plane-sg"))}"
  ingress {
    from_port   = "0"
    to_port     = "65000"
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/8"]
  }
  ingress {
    from_port   = "443"
    to_port     = "443"
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/8"]
  }
  # ssh
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/8"]
  }
  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }
}
*/


# EKS cluster

resource "aws_eks_cluster" "app" {
  count = "${var.ekscluster}"
  name = "${var.prefix}-${var.appname}-${var.envname}"
  role_arn = "arn:aws:iam::584913898247:role/EKS-Master"
  version  = "${var.cluster_version}"
  vpc_config {
    # security_group_ids = ["${aws_security_group.eks-control-plane-sg.id}"]
    security_group_ids = ["${module.security.appsec}"]
    subnet_ids = [ "${var.subnet2a}", "${var.subnet2b}", "${var.subnet2c}", "${var.subnet2d}" ]
  }
}


resource "null_resource" "kubeconfig-local" {
  count = "${var.ekscluster}"

  triggers {
     now = "${timestamp()}"
  } 

  provisioner "local-exec" {
    command = <<LOCAL_EXEC

cat >> proxy-env-vars.yaml << PROXYENV
apiVersion: v1
kind: ConfigMap
metadata:
  name: proxy-environment-variables
  namespace: kube-system
data:
  NO_PROXY: artifcatrepo,artifcatrepo.qa.tpp.tsysecom.com,10.32.6.113,ec2.us-east-1.amazonaws.com,s3.amazonaws.com,127.0.0.1,localhost,.internal,100.64.0.1,100.64.0.0/10,169.254.169.254,10.35.8.0/21,172.20.0.0/16,.tpp.tsysecom.com
  HTTP_PROXY: http://di-proxy.us-east-1.aws-tsys:4438
  HTTPS_PROXY: http://di-proxy.us-east-1.aws-tsys:4438
PROXYENV

cat >> config-map-aws-auth.yaml << AWSAUTH
apiVersion: v1
kind: ConfigMap
metadata:
  name: aws-auth
  namespace: kube-system
data:
  mapRoles: |
    - rolearn: arn:aws:iam::584913898247:role/EKS-Node
      username: system:node:{{EC2PrivateDNSName}}
      groups:
        - system:bootstrappers
        - system:nodes
AWSAUTH

cat >> kubeconfig.yaml << KUBECONF
apiVersion: v1
clusters:
- cluster:
    server: ${aws_eks_cluster.app.endpoint}
    certificate-authority-data: ${aws_eks_cluster.app.certificate_authority.0.data}
  name: arn:aws:eks:us-east-1:584913898247:cluster/${var.prefix}-${var.appname}-${var.envname}
contexts:
- context:
    cluster: arn:aws:eks:us-east-1:584913898247:cluster/${var.prefix}-${var.appname}-${var.envname}
    user: arn:aws:eks:us-east-1:584913898247:cluster/${var.prefix}-${var.appname}-${var.envname}
  name: aws
current-context: aws
kind: Config
preferences: {}
users:
- name: arn:aws:eks:us-east-1:584913898247:cluster/${var.prefix}-${var.appname}-${var.envname}
  user:
    exec:
      apiVersion: client.authentication.k8s.io/v1alpha1
      command: aws-iam-authenticator
      args:
        - "token"
        - "-i"
        - ${var.prefix}-${var.appname}-${var.envname}
KUBECONF

sleep 90 & echo \"sleeping in PID $!\"
aws eks update-kubeconfig --name ${var.prefix}-${var.appname}-${var.envname}
sleep 90 & echo \"sleeping in PID $!\"
kubectl apply -f config-map-aws-auth.yaml --kubeconfig kubeconfig.yaml
sleep 90 & echo \"sleeping in PID $!\"
kubectl apply -f proxy-env-vars.yaml --kubeconfig kubeconfig.yaml
sleep 90 & echo \"sleeping in PID $!\"
kubectl apply -f config-map-aws-auth.yaml
sleep 90 & echo \"sleeping in PID $!\"
kubectl apply -f proxy-env-vars.yaml
sleep 90 & echo \"sleeping in PID $!\"
kubectl set env daemonset/kube-proxy --namespace=kube-system --from=configmap/proxy-environment-variables --containers='*'
kubectl set env daemonset/aws-node --namespace=kube-system --from=configmap/proxy-environment-variables --containers='*'
kubectl set env daemonset -n kube-system aws-node AWS_VPC_K8S_CNI_EXTERNALSNAT=true
kubectl set env daemonset -n kube-system aws-node AWS_VPC_K8S_CNI_CUSTOM_NETWORK_CFG=true
rm -f config-map-aws-auth.yaml kubeconfig.yaml proxy-env-vars.yaml

LOCAL_EXEC
  }
}

