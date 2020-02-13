# see inputs.tf for configurable variables

# database

resource "aws_db_instance" "app" {
  count             = "${ var.db_size > 0 ? 1 : 0 }"
  name              = "${ var.db_name=="default"?"${var.prefix}${var.appname}${var.envname}":"${var.db_name}" }"
  identifier        = "${var.prefix}-${var.appname}-${var.envname}"
  engine            = "postgres"
  engine_version    = "9.6.11"
  allocated_storage = "${var.db_size}"
  storage_encrypted = "true"
  storage_type      = "gp2"
  instance_class    = "${var.db_class}"
  username = "${var.prefix}${var.appname}${var.envname}"
  password = "${random_string.dbpass.result}"
  apply_immediately = "true" # caution
  backup_retention_period = 14
  skip_final_snapshot = "true" 
  iam_database_authentication_enabled = true
  db_subnet_group_name = "${aws_db_subnet_group.default.id}"
  vpc_security_group_ids = ["${module.security.rdssec}"]
  multi_az = "${var.db_ha==0?"false":"true"}"
  deletion_protection = "${var.db_protect==0?"false":"true"}"
  tags {
    Name = "${var.prefix}-${var.appname}-${var.envname}"
    NonStop = "${var.nonstop}"
    Application = "${var.prefix}-${var.appname}-${var.envname}"
    KubernetesCluster = "${var.prefix}-${var.appname}-${var.envname}"
    Department = "${var.prefix}"
  }
}

# add database to route53 zone

resource "aws_route53_record" "dbdns" {
  count = "${var.db_size > 0 ? 1 : 0}"
  zone_id = "${data.aws_route53_zone.selected.zone_id}"
  name = "${var.prefix}-${var.appname}-${var.envname}-db"
  type = "A"
  alias {
    name = "${aws_db_instance.app.address}"
    zone_id = "${aws_db_instance.app.hosted_zone_id}"
    evaluate_target_health = false
  }
}



# output database information as SSM parameters and module outputs

// output "db_dbname" { value = "${var.db_size>0?aws_db_instance.app.name:"null"}" }

resource "aws_ssm_parameter" "dbname" {
  count = "${ var.db_size > 0 ? 1 : 0 }"
  name  = "/${var.prefix}/${var.envname}/${var.appname}/db/name"
  type  = "String"
  value = "${aws_db_instance.app.name}"
  overwrite = "true"
}

resource "aws_ssm_parameter" "dbid" {
  count = "${ var.db_size > 0 ? 1 : 0 }"
  name  = "/${var.prefix}/${var.envname}/${var.appname}/db/id"
  type  = "String"
  value = "${aws_db_instance.app.identifier}"
  overwrite = "true"
}

// output "db_endpoint" { value = "${aws_db_instance.app.endpoint}" }

resource "aws_ssm_parameter" "endpoint" {
  count = "${ var.db_size > 0 ? 1 : 0 }"
  name  = "/${var.prefix}/${var.envname}/${var.appname}/db/endpoint"
  type  = "String"
  value = "${aws_db_instance.app.endpoint}"
  overwrite = "true"
}

// output "db_username" { value = "${aws_db_instance.app.username}" }

resource "aws_ssm_parameter" "dbuser" {
  count = "${ var.db_size > 0 ? 1 : 0 }"
  name  = "/${var.prefix}/${var.envname}/${var.appname}/db/username"
  type  = "String"
  value = "${aws_db_instance.app.username}"
  overwrite = "true"
}

// output "db_password" { value = "${aws_db_instance.app.password}" }

resource "aws_ssm_parameter" "dbpass" {
  count = "${ var.db_size > 0 ? 1 : 0 }"
  name  = "/${var.prefix}/${var.envname}/${var.appname}/db/password"
  type  = "SecureString"
  value = "${aws_db_instance.app.password}"
  overwrite = "true"
}

# restore database

resource "aws_db_instance" "restore" {
  count             = "${ var.db_restore_from != "" ? 1 : 0 }"
  name              = "${var.prefix}${var.appname}${var.envname}restore"
  identifier        = "${var.prefix}-${var.appname}-${var.envname}-restore"
  engine            = "postgres"
  engine_version    = "9.6.11"
  allocated_storage = "${var.db_size}"
  storage_encrypted = "true"
  storage_type      = "gp2"
  instance_class    = "${var.db_class}"
  username = "${var.prefix}${var.appname}${var.envname}"
  password = "${random_string.dbpass.result}"
  apply_immediately = "true" # caution
  backup_retention_period = 14
  skip_final_snapshot = "true" 
  snapshot_identifier = "${var.db_restore_from}"
  iam_database_authentication_enabled = true
  db_subnet_group_name = "${aws_db_subnet_group.default.id}"
  vpc_security_group_ids = ["${module.security.rdssec}"]
  multi_az = "${var.db_ha==0?"false":"true"}"
  deletion_protection = "${var.db_protect==0?"false":"true"}"
  tags {
    Name = "${var.prefix}-${var.appname}-${var.envname}"
    NonStop = "${var.nonstop}"
    Application = "${var.prefix}-${var.appname}-${var.envname}"
    KubernetesCluster = "${var.prefix}-${var.appname}-${var.envname}"
    Department = "${var.prefix}"
  }
}

# add database to route53 zone

resource "aws_route53_record" "dbdnsrestore" {
  count = "${ var.db_restore_from != "" ? 1 : 0 }"
  zone_id = "${data.aws_route53_zone.selected.zone_id}"
  name = "${var.prefix}-${var.appname}-${var.envname}-dbrestore"
  type = "A"
  alias {
    name = "${aws_db_instance.restore.address}"
    zone_id = "${aws_db_instance.restore.hosted_zone_id}"
    evaluate_target_health = false
  }
}



# output database information as SSM parameters

resource "aws_ssm_parameter" "restdbname" {
  count = "${ var.db_restore_from != "" ? 1 : 0 }"
  name  = "/${var.prefix}/${var.envname}/${var.appname}/dbrestore/name"
  type  = "String"
  value = "${aws_db_instance.restore.name}"
  overwrite = "true"
}

resource "aws_ssm_parameter" "restendpoint" {
  count = "${ var.db_restore_from != "" ? 1 : 0 }"
  name  = "/${var.prefix}/${var.envname}/${var.appname}/dbrestore/endpoint"
  type  = "String"
  value = "${aws_db_instance.restore.endpoint}"
  overwrite = "true"
}

resource "aws_ssm_parameter" "restdbuser" {
  count = "${ var.db_restore_from != "" ? 1 : 0 }"
  name  = "/${var.prefix}/${var.envname}/${var.appname}/dbrestore/username"
  type  = "String"
  value = "${aws_db_instance.restore.username}"
  overwrite = "true"
}

resource "aws_ssm_parameter" "restdbpass" {
  count = "${ var.db_restore_from != "" ? 1 : 0 }"
  name  = "/${var.prefix}/${var.envname}/${var.appname}/dbrestore/password"
  type  = "SecureString"
  value = "${aws_db_instance.restore.password}"
  overwrite = "true"
}


resource "random_string" "dbpass" {
  count       = "${ var.db_size > 0 ? 1 : 0 }"
  length      = 32
  min_upper   = 4
  min_lower   = 4
  min_numeric = 4

  // Harbor config file has trouble with special characters (per Aditya)
  // min_special = 4 
  // override_special = "!-_=+[]{}:?" # RDS doesn't like @ signs

  special = false

}


resource "aws_db_subnet_group" "default" {
  count       = "${ var.db_size > 0 ? 1 : 0 }"
  name       = "${var.prefix}-${var.appname}-${var.envname}"
  subnet_ids = ["${var.subnetspriv}"]
  tags {
    Name = "DB subnet group"
  }
}

