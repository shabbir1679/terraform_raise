### NFS1

resource "aws_ebs_volume" "nfs1" {
  count = "${ var.nfs_size > 0 ? 1 : 0 }"
  availability_zone = "us-east-1c"
  size = "${var.nfs_size}"
  tags = {
      Name = "${var.prefix}-${var.appname}-${var.envname}-nfs1" 
      Application = "${var.prefix}-${var.appname}-${var.envname}" 
      KubernetesCluster = "${var.prefix}-${var.appname}-${var.envname}" 
  }
}

resource "aws_ssm_parameter" "nfsvolume1" {
  count = "${ var.nfs_size > 0 ? 1 : 0 }"
  name  = "/${var.prefix}/${var.envname}/${var.appname}/nfs1/volume"
  type  = "String"
  value = "${aws_ebs_volume.nfs1.id}"
  overwrite = "true"
}

resource "aws_ebs_volume" "nfs1-bk" {
  count = "${ var.nfs_size > 0 ? 1 : 0 }"
  availability_zone = "us-east-1c"
  size = "${var.nfs_size}"
  tags = {
      Name = "${var.prefix}-${var.appname}-${var.envname}-nfs1-bk" 
      Application = "${var.prefix}-${var.appname}-${var.envname}" 
      KubernetesCluster = "${var.prefix}-${var.appname}-${var.envname}" 
  }
}

resource "aws_ssm_parameter" "nfsvolume1bk" {
  count = "${ var.nfs_size > 0 ? 1 : 0 }"
  name  = "/${var.prefix}/${var.envname}/${var.appname}/nfs1/volume-bk"
  type  = "String"
  value = "${aws_ebs_volume.nfs1-bk.id}"
  overwrite = "true"
}


resource "aws_launch_template" "nfs1" {
  count = "${ var.nfs_size > 0 ? 1 : 0 }"
  name = "${var.prefix}-${var.appname}-${var.envname}-nfs1"
  iam_instance_profile = { arn = "arn:aws:iam::584913898247:instance-profile/DevOps-Engineer-Profile" }
  image_id = "${var.nfs_ami}"
  key_name = "${var.keyname}"
  instance_type = "${var.nfs_instance}"
  instance_initiated_shutdown_behavior = "terminate"
  monitoring { enabled = true }
  vpc_security_group_ids = ["${module.security.appsec}"]
  tags { Name = "${var.prefix}-${var.appname}-${var.envname}-nfs" }
  tag_specifications {
    resource_type = "instance"
    tags { 
      Name = "${var.prefix}-${var.appname}-${var.envname}-nfs" 
      NonStop = "${var.nonstop}"
      Application = "${var.prefix}-${var.appname}-${var.envname}" 
      KubernetesCluster = "${var.prefix}-${var.appname}-${var.envname}" 
      Department = "${var.prefix}"
    }
  }
  user_data = "${base64encode(local.nfs1_start)}"
  block_device_mappings {
    device_name = "/dev/xvda"
    ebs {
      volume_size = 40
    }
  }
}

resource "aws_autoscaling_group" "nfs1" {
  count = "${ var.nfs_size > 0 ? 1 : 0 }"
  name = "${var.prefix}-${var.appname}-${var.envname}-nfs1"
  max_size = 1
  min_size = 1
  launch_template = {
    id = "${aws_launch_template.nfs1.id}"
    version = "$$Latest"
  }   
  vpc_zone_identifier = ["${var.subnet2c}"]
  enabled_metrics = ["GroupMinSize", "GroupMaxSize", "GroupDesiredCapacity", "GroupInServiceInstances", "GroupPendingInstances", "GroupStandbyInstances", "GroupTerminatingInstances", "GroupTotalInstances"]
  tag {
    key = "Name"
    value = "${var.prefix}-${var.appname}-${var.envname}-nfs1" 
    propagate_at_launch = true
  }
  tag {
    key = "NonStop"
    value = "${var.nonstop}"
    propagate_at_launch = true
  }
  tag {
    key = "Application"
    value = "${var.prefix}-${var.appname}-${var.envname}" 
    propagate_at_launch = true
  }
  tag {
    key = "KubernetesCluster"
    value = "${var.prefix}-${var.appname}-${var.envname}" 
    propagate_at_launch = true
  }
  tag {
    key = "Department"
    value = "${var.prefix}"
    propagate_at_launch = true
  }
}

locals {
nfs1_start = <<EOF
#!/bin/sh  
yum -y install aws-cli
aws s3 cp s3://${var.s3bucket}/${var.scriptspath}/setup-nfs.sh /tmp
sh /tmp/setup-nfs.sh ${var.envname} ${var.appname} ${var.s3bucket} 1 2 >> /tmp/start.log 2>&1 
EOF
}



### NFS2

resource "aws_ebs_volume" "nfs2" {
  count = "${ var.nfs_size > 0 ? 1 : 0 }"
  availability_zone = "us-east-1d"
  size = "${var.nfs_size}"
  tags = {
      Name = "${var.prefix}-${var.appname}-${var.envname}-nfs2" 
      Application = "${var.prefix}-${var.appname}-${var.envname}" 
      KubernetesCluster = "${var.prefix}-${var.appname}-${var.envname}" 
  }
}

resource "aws_ssm_parameter" "nfsvolume2" {
  count = "${ var.nfs_size > 0 ? 1 : 0 }"
  name  = "/${var.prefix}/${var.envname}/${var.appname}/nfs2/volume"
  type  = "String"
  value = "${aws_ebs_volume.nfs2.id}"
  overwrite = "true"
}

resource "aws_ebs_volume" "nfs2-bk" {
  count = "${ var.nfs_size > 0 ? 1 : 0 }"
  availability_zone = "us-east-1d"
  size = "${var.nfs_size}"
  tags = {
      Name = "${var.prefix}-${var.appname}-${var.envname}-nfs2-bk" 
      Application = "${var.prefix}-${var.appname}-${var.envname}" 
      KubernetesCluster = "${var.prefix}-${var.appname}-${var.envname}" 
  }
}

resource "aws_ssm_parameter" "nfsvolume2-bk" {
  count = "${ var.nfs_size > 0 ? 1 : 0 }"
  name  = "/${var.prefix}/${var.envname}/${var.appname}/nfs2/volume-bk"
  type  = "String"
  value = "${aws_ebs_volume.nfs2-bk.id}"
  overwrite = "true"
}

resource "aws_launch_template" "nfs2" {
  count = "${ var.nfs_size > 0 ? 1 : 0 }"
  name = "${var.prefix}-${var.appname}-${var.envname}-nfs2"
  iam_instance_profile = { arn = "arn:aws:iam::584913898247:instance-profile/DevOps-Engineer-Profile" }
  image_id = "${var.nfs_ami}"
  key_name = "${var.keyname}"
  instance_type = "${var.nfs_instance}"
  instance_initiated_shutdown_behavior = "terminate"
  monitoring { enabled = true }
  vpc_security_group_ids = ["${module.security.appsec}"]
  tags { Name = "${var.prefix}-${var.appname}-${var.envname}-nfs" }
  tag_specifications {
    resource_type = "instance"
    tags { 
      Name = "${var.prefix}-${var.appname}-${var.envname}-nfs" 
      NonStop = "${var.nonstop}"
      Application = "${var.prefix}-${var.appname}-${var.envname}" 
      KubernetesCluster = "${var.prefix}-${var.appname}-${var.envname}" 
      Department = "${var.prefix}"
    }
  }
  user_data = "${base64encode(local.nfs2_start)}"
  block_device_mappings {
    device_name = "/dev/xvda"
    ebs {
      volume_size = 40
    }
  }
}

resource "aws_autoscaling_group" "nfs2" {
  count = "${ var.nfs_size > 0 ? 1 : 0 }"
  name = "${var.prefix}-${var.appname}-${var.envname}-nfs2"
  max_size = 1
  min_size = 1
  launch_template = {
    id = "${aws_launch_template.nfs2.id}"
    version = "$$Latest"
  }   
  vpc_zone_identifier = ["${var.subnet2d}"]
  enabled_metrics = ["GroupMinSize", "GroupMaxSize", "GroupDesiredCapacity", "GroupInServiceInstances", "GroupPendingInstances", "GroupStandbyInstances", "GroupTerminatingInstances", "GroupTotalInstances"]
  tag {
    key = "Name"
    value = "${var.prefix}-${var.appname}-${var.envname}-nfs2" 
    propagate_at_launch = true
  }
  tag {
    key = "NonStop"
    value = "${var.nonstop}"
    propagate_at_launch = true
  }
  tag {
    key = "Application"
    value = "${var.prefix}-${var.appname}-${var.envname}" 
    propagate_at_launch = true
  }
  tag {
    key = "KubernetesCluster"
    value = "${var.prefix}-${var.appname}-${var.envname}" 
    propagate_at_launch = true
  }
  tag {
    key = "Department"
    value = "${var.prefix}"
    propagate_at_launch = true
  }
}


locals {
nfs2_start = <<EOF
#!/bin/sh  
yum -y install aws-cli
aws s3 cp s3://${var.s3bucket}/${var.scriptspath}/setup-nfs.sh /tmp
sh /tmp/setup-nfs.sh ${var.envname} ${var.appname} ${var.s3bucket} 2 1 >> /tmp/start.log 2>&1 
EOF
}

### shared secret for DRBD

resource "aws_ssm_parameter" "drbdsecret" {
  count = "${ var.nfs_size > 0 ? 1 : 0 }"
  name  = "/${var.prefix}/${var.envname}/${var.appname}/nfs/drbdsecret"
  type  = "SecureString"
  value = "${random_string.drbdsecret.result}"
  overwrite = "true"
}


resource "random_string" "drbdsecret" {
  count = "${ var.nfs_size > 0 ? 1 : 0 }"
  length      = 16
  min_upper   = 4
  min_lower   = 4
  min_numeric = 4

  special = false

}
