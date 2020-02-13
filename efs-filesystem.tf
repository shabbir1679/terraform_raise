# see inputs.tf for configurable variables


# shared filesystem - bursting performance
resource "aws_efs_file_system" "app" {
  count = "${var.sharedfs}"
  tags { 
    Name = "${var.prefix}-${var.appname}-${var.envname}" 
    Application = "${var.prefix}-${var.appname}-${var.envname}" 
    KubernetesCluster = "${var.prefix}-${var.appname}-${var.envname}" 
    Department = "${var.prefix}"
  }
  creation_token = "${var.prefix}-${var.appname}-${var.envname}" 
  throughput_mode = "${var.efs_mode}"
  provisioned_throughput_in_mibps = "${var.efs_mibps}"
}


# output parameter with filesystem's mount name
resource "aws_ssm_parameter" "efsmount" {
  count = "${var.sharedfs}"
  name  = "/${var.prefix}/${var.envname}/${var.appname}/fs/dnsname"
  type  = "String"
  value = "${aws_efs_file_system.app.dns_name}"
  overwrite = "true"
}



resource "aws_efs_mount_target" "app2a" {
  count = "${var.sharedfs}"
  file_system_id  = "${aws_efs_file_system.app.id}"
  subnet_id       = "${var.subnet2a}"
  security_groups = ["${module.security.efssec}"]

}

resource "aws_efs_mount_target" "app2b" {
  count = "${var.sharedfs}"
  file_system_id = "${aws_efs_file_system.app.id}"
  subnet_id      = "${var.subnet2b}"
  security_groups = ["${module.security.efssec}"]
}

resource "aws_efs_mount_target" "app2c" {
  count = "${var.sharedfs}"
  file_system_id  = "${aws_efs_file_system.app.id}"
  subnet_id       = "${var.subnet2c}"
  security_groups = ["${module.security.efssec}"]

}

resource "aws_efs_mount_target" "app2d" {
  count = "${var.sharedfs}"
  file_system_id = "${aws_efs_file_system.app.id}"
  subnet_id      = "${var.subnet2d}"
  security_groups = ["${module.security.efssec}"]
}


