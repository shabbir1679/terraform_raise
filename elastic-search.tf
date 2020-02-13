# see inputs.tf for configurable variables

# ElasticSearch 


resource "aws_elasticsearch_domain" "app" {
  count = "${var.es_size>0 ? 1 : 0}"
  domain_name           = "${var.prefix}${var.appname}${var.envname}"
  elasticsearch_version = "6.5"

  # encrypt_at_rest       = { enabled = "${var.es_encrypt}" }

  cluster_config {
    instance_type = "${var.es_instance_type}"
    instance_count = "${var.es_instance_count}"
    zone_awareness_enabled = true
  }

  vpc_options {
    security_group_ids = ["${module.security.essec}"]
    subnet_ids = ["${var.es_subnet1}", "${var.es_subnet2}"]
  }
  
  ebs_options {
    ebs_enabled = "true"
    volume_size = "${var.es_size}"
    volume_type = "gp2"
  }
  snapshot_options {
    automated_snapshot_start_hour = 23
  }

  tags {
    Application = "${var.prefix}-${var.appname}-${var.envname}"
    KubernetesCluster = "${var.prefix}-${var.appname}-${var.envname}"
    Department = "${var.prefix}"
  }
  

  access_policies = <<EOF
    {
      "Version": "2012-10-17",
      "Statement": [
         {
           "Effect": "Allow",
           "Principal": {
             "AWS": "*"
           },
           "Action": "es:*",
           "Resource": "arn:aws:es:us-east-1:584913898247:domain/${var.prefix}${var.appname}${var.envname}/*"
         }
       ]
     }
   EOF
}


resource "aws_ssm_parameter" "esendpoint" {
  count = "${var.es_size>0 ? 1 : 0}"
  name  = "/${var.prefix}/${var.envname}/${var.appname}/es/endpoint"
  type  = "String"
  value = "${aws_elasticsearch_domain.app.endpoint}"
  overwrite = "true"
}


data "aws_region" "current" {}

resource "aws_ssm_parameter" "esawsregion" {
  count = "${var.es_size>0 ? 1 : 0}"
  name  = "/${var.prefix}/${var.envname}/${var.appname}/es/region"
  type  = "String"
  value = "${data.aws_region.current.name}"
  overwrite = "true"
}


