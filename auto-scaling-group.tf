# see inputs.tf for configurable variables

# launch template - used by autoscaling group to launch new EC2 instances

resource "aws_launch_template" "app" {
  count = "${ var.max_instances > 0 ? 1 : 0 }"
  name = "${var.prefix}-${var.appname}-${var.envname}"
  iam_instance_profile = { arn = "${var.profile}" }
  image_id = "${var.ami=="default"?(var.ekscluster==1?data.aws_ami.eksami.id:(var.ecscluster==1?data.aws_ami.ecsami.id:data.aws_ami.baseami.id)):var.ami}"
  key_name = "${var.keyname}"
  instance_type = "${var.instance_type}"
  instance_initiated_shutdown_behavior = "terminate"
  monitoring { enabled = true }
  vpc_security_group_ids = ["${module.security.appsec}"]

  tags { Name = "${var.prefix}-${var.appname}-${var.envname}" }

  tag_specifications {
    resource_type = "instance"
    tags { 
      Name = "${var.prefix}-${var.appname}-${var.envname}" 
      NonStop = "${var.nonstop}"
      Application = "${var.prefix}-${var.appname}-${var.envname}" 
      KubernetesCluster = "${var.prefix}-${var.appname}-${var.envname}" 
      Department = "${var.prefix}"
      InfoSec = "${var.infosectag}"
    }
  }

  user_data = "${base64encode(var.chefmaster>0 ? local.chefmaster_start : local.chefclient_start) }"
  
  block_device_mappings {
    device_name = "/dev/xvda"
    ebs {
      volume_size = "${var.instance_storage}"
    }
  }

  instance_market_options = "${var.market_options}"

}


# autoscaling group - creates instances as needed, destroys when no longer needed

resource "aws_autoscaling_group" "app" {
  count = "${ var.max_instances > 0 ? 1 : 0 }"
  name = "${var.prefix}-${var.appname}-${var.envname}"
  max_size = "${var.max_instances}"
  min_size = "${var.min_instances}"
  launch_template = {
    id = "${aws_launch_template.app.id}"
    version = "$$Latest"
  }   
  target_group_arns = [ "${aws_lb_target_group.app.id}", "${aws_lb_target_group.nlb.id}", "${aws_lb_target_group.app2.id}", "${aws_lb_target_group.app3.id}" ] 
  vpc_zone_identifier = "${var.subnets}"
  health_check_type = "${var.autoscale_health_check}"
  enabled_metrics = ["GroupMinSize", "GroupMaxSize", "GroupDesiredCapacity", "GroupInServiceInstances", "GroupPendingInstances", "GroupStandbyInstances", "GroupTerminatingInstances", "GroupTotalInstances"]
  tag {
    key = "Name"
    value = "${var.prefix}-${var.appname}-${var.envname}" 
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
  tag {
    key = "${var.ekscluster==1?"kubernetes.io/cluster/":"no-cluster/"}${var.prefix}-${var.appname}-${var.envname}" 
    value = "owned"
    propagate_at_launch = true
  }
  tag {
    key = "InfoSec"
    value = "${var.infosectag}"
    propagate_at_launch = true
  }
}


# automatically launches and terminates instances based on load

resource "aws_autoscaling_policy" "app" {
  count = "${var.autoscale}"
  name = "${var.prefix}-${var.appname}-${var.envname}"
  autoscaling_group_name = "${aws_autoscaling_group.app.name}"
  policy_type = "TargetTrackingScaling"
  target_tracking_configuration {
    predefined_metric_specification { 
      predefined_metric_type = "ASGAverageCPUUtilization"
    }
    target_value = "${var.autoscale_cpu_target}"
  }
}


# commands to run to set up application on a new instance
# passed by Launch Template as User Data to each new EC2 Instance

locals {
chefclient_start = <<EOF
#!/bin/sh  
yum -y install aws-cli
aws s3 cp s3://${var.s3bucket}/${var.scriptspath}/setup-chefclient.sh /tmp
sh /tmp/setup-chefclient.sh ${var.envname} ${var.appname} ${var.s3bucket} >> /tmp/start.log 2>&1 

EOF
}

locals {
chefmaster_start = <<EOF
#!/bin/sh  

aws s3 cp s3://${var.s3bucket}/${var.scriptspath}/setup-chefmaster.sh /tmp
sh /tmp/setup-chefmaster.sh >> /tmp/start.log 2>&1 

EOF
}

