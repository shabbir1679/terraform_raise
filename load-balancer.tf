# see inputs.txt for configurable variables


### ALB - works at HTTPS and HTTP level

# listener - specifies how load balancer takes incoming traffic

resource "aws_lb_listener" "app" {
  count = "${var.target_port > 0 ? 1 : 0}"
  load_balancer_arn = "${aws_lb.app.id}"
  port = "${var.listen_port}"
  protocol = "${var.listen_proto}"
  default_action {
    type = "forward" 
    target_group_arn = "${aws_lb_target_group.app.id}"
  }
  ssl_policy = "ELBSecurityPolicy-2016-08"
  certificate_arn = "${var.certificate_arn}"
}


# load balancer - routes traffic across available targets

resource "aws_lb" "app" {
  count = "${var.target_port > 0 ? 1 : 0}"
  name = "${var.prefix}-${var.appname}-${var.envname}"
  tags {
    Name = "${var.prefix}-${var.appname}-${var.envname}"
    Application = "${var.prefix}-${var.appname}-${var.envname}"
    KubernetesCluster = "${var.prefix}-${var.appname}-${var.envname}"
    Department = "${var.prefix}"
  }
  load_balancer_type = "application"
  idle_timeout = "${var.idle_timeout}"
  internal = "true"
  subnets = [ "${var.subnetspub}" ]
  security_groups = ["${module.security.albsec}"]
  enable_cross_zone_load_balancing = "true"
}


# output parameter with load balancer's dns name

resource "aws_ssm_parameter" "lbdns" {
  count = "${var.target_port > 0 ? 1 : 0}"
  name  = "/${var.prefix}/${var.envname}/${var.appname}/lb/dnsname"
  type  = "String"
  value = "${aws_lb.app.dns_name}"
  overwrite = "true"
}


# add load balancer to route53 zone
resource "aws_route53_record" "app" {
  count = "${var.target_port > 0 ? 1 : 0}"
  zone_id = "${data.aws_route53_zone.selected.zone_id}"
  name = "${var.prefix}-${var.appname}-${var.envname}"
  type = "A"
  alias {
    name = "${aws_lb.app.dns_name}"
    zone_id = "${aws_lb.app.zone_id}"
    evaluate_target_health = false
  }
}

# target group - load balancer routes traffic to it, autoscaling group adds instances to it
resource "aws_lb_target_group" "app" {
  name_prefix = "${substr(var.envname,0,3)}${substr(var.appname,0,3)}"
  tags { name = "${var.prefix}-${var.appname}-${var.envname}" }
  port = "${ var.target_port > 0 ? var.target_port : 9999 }" 
  protocol = "${var.target_proto}" 
  vpc_id = "${var.vpc}"
  lifecycle { create_before_destroy = true }
  health_check { 
    path = "${var.health_path}" 
    protocol = "${var.target_proto}"
    interval = 10
    healthy_threshold = 2
    unhealthy_threshold = 2
  }
  stickiness { type = "lb_cookie" }
}

resource "aws_route53_record" "app_friendly" {
  count = "${(var.target_port > 0 && var.dnsname != "none") ? 1 : 0}"
  zone_id = "${data.aws_route53_zone.selected.zone_id}"
  name = "${var.dnsname}"
  type = "A"
  alias {
    name = "${aws_lb.app.dns_name}"
    zone_id = "${aws_lb.app.zone_id}"
    evaluate_target_health = false
  }
}

### second ALB

# listener - specifies how load balancer takes incoming traffic

resource "aws_lb_listener" "app2" {
  count = "${var.target2_port > 0 ? 1 : 0}"
  load_balancer_arn = "${aws_lb.app2.id}"
  port = "${var.listen_port}"
  protocol = "${var.listen_proto}"
  default_action {
    type = "forward" 
    target_group_arn = "${aws_lb_target_group.app2.id}"
  }
  ssl_policy = "ELBSecurityPolicy-2016-08"
  certificate_arn = "${var.certificate_arn}"
}


# load balancer - routes traffic across available targets

resource "aws_lb" "app2" {
  count = "${var.target2_port > 0 ? 1 : 0}"
  name = "${var.prefix}-${var.appname}-${var.envname}-2"
  tags {
    Name = "${var.prefix}-${var.appname}-${var.envname}-2"
    Application = "${var.prefix}-${var.appname}-${var.envname}"
    KubernetesCluster = "${var.prefix}-${var.appname}-${var.envname}"
    Department = "${var.prefix}"
  }
  load_balancer_type = "application"
  idle_timeout = "${var.idle_timeout}"
  internal = "true"
  subnets = [ "${var.subnetspub}" ]
  security_groups = ["${module.security.albsec}"]
  enable_cross_zone_load_balancing = "true"
}


# output parameter with load balancer's dns name

resource "aws_ssm_parameter" "lbdns2" {
  count = "${var.target2_port > 0 ? 1 : 0}"
  name  = "/${var.prefix}/${var.envname}/${var.appname}/lb2/dnsname"
  type  = "String"
  value = "${aws_lb.app2.dns_name}"
  overwrite = "true"
}

# add load balancer to route53 zone
resource "aws_route53_record" "app2" {
  count = "${var.target2_port > 0 ? 1 : 0}"
  zone_id = "${data.aws_route53_zone.selected.zone_id}"
  name = "${var.prefix}-${var.appname}-${var.envname}-2"
  type = "A"
  alias {
    name = "${aws_lb.app2.dns_name}"
    zone_id = "${aws_lb.app2.zone_id}"
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "app2_friendly" {
  count = "${(var.target2_port > 0 && var.dnsname2 != "none") ? 1 : 0}"
  zone_id = "${data.aws_route53_zone.selected.zone_id}"
  name = "${var.dnsname2}"
  type = "A"
  alias {
    name = "${aws_lb.app2.dns_name}"
    zone_id = "${aws_lb.app2.zone_id}"
    evaluate_target_health = false
  }
}


# target group - load balancer routes traffic to it, autoscaling group adds instances to it
resource "aws_lb_target_group" "app2" {
  name_prefix = "${substr(var.envname,0,3)}${substr(var.appname,0,3)}"
  tags { name = "${var.prefix}-${var.appname}-${var.envname}-2" }
  port = "${ var.target2_port > 0 ? var.target2_port : 9999 }" 
  protocol = "${var.target_proto}" 
  vpc_id = "${var.vpc}"
  lifecycle { create_before_destroy = true }
  health_check { 
    path = "${var.health_path}" 
    protocol = "${var.target_proto}"
    port     = "${var.target_port > 0 ? var.target_port : 9999 }" // note, not target2_port
    interval = 10
    healthy_threshold = 2
    unhealthy_threshold = 2
  }
  stickiness { type = "lb_cookie" }
}


### third ALB

# listener - specifies how load balancer takes incoming traffic

resource "aws_lb_listener" "app3" {
  count = "${var.target3_port > 0 ? 1 : 0}"
  load_balancer_arn = "${aws_lb.app3.id}"
  port = "${var.listen_port}"
  protocol = "${var.listen_proto}"
  default_action {
    type = "forward" 
    target_group_arn = "${aws_lb_target_group.app3.id}"
  }
  ssl_policy = "ELBSecurityPolicy-2016-08"
  certificate_arn = "${var.certificate_arn}"
}


# load balancer - routes traffic across available targets

resource "aws_lb" "app3" {
  count = "${var.target3_port > 0 ? 1 : 0}"
  name = "${var.prefix}-${var.appname}-${var.envname}-3"
  tags {
    Name = "${var.prefix}-${var.appname}-${var.envname}-3"
    Application = "${var.prefix}-${var.appname}-${var.envname}"
    KubernetesCluster = "${var.prefix}-${var.appname}-${var.envname}"
    Department = "${var.prefix}"
  }
  load_balancer_type = "application"
  idle_timeout = "${var.idle_timeout}"
  internal = "true"
  subnets = [ "${var.subnetspub}" ]
  security_groups = ["${module.security.albsec}"]
  enable_cross_zone_load_balancing = "true"
}


# output parameter with load balancer's dns name

resource "aws_ssm_parameter" "lbdns3" {
  count = "${var.target3_port > 0 ? 1 : 0}"
  name  = "/${var.prefix}/${var.envname}/${var.appname}/lb3/dnsname"
  type  = "String"
  value = "${aws_lb.app3.dns_name}"
  overwrite = "true"
}

# add load balancer to route53 zone
resource "aws_route53_record" "app3" {
  count = "${var.target2_port > 0 ? 1 : 0}"
  zone_id = "${data.aws_route53_zone.selected.zone_id}"
  name = "${var.prefix}-${var.appname}-${var.envname}-3"
  type = "A"
  alias {
    name = "${aws_lb.app3.dns_name}"
    zone_id = "${aws_lb.app3.zone_id}"
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "app3_friendly" {
  count = "${(var.target3_port > 0 && var.dnsname2 != "none") ? 1 : 0}"
  zone_id = "${data.aws_route53_zone.selected.zone_id}"
  name = "${var.dnsname3}"
  type = "A"
  alias {
    name = "${aws_lb.app3.dns_name}"
    zone_id = "${aws_lb.app3.zone_id}"
    evaluate_target_health = false
  }
}


# target group - load balancer routes traffic to it, autoscaling group adds instances to it
resource "aws_lb_target_group" "app3" {
  name_prefix = "${substr(var.envname,0,3)}${substr(var.appname,0,3)}"
  tags { name = "${var.prefix}-${var.appname}-${var.envname}-3" }
  port = "${ var.target3_port > 0 ? var.target3_port : 9999 }" 
  protocol = "${var.target_proto}" 
  vpc_id = "${var.vpc}"
  lifecycle { create_before_destroy = true }
  health_check { 
    path = "${var.health_path}" 
    protocol = "${var.target_proto}"
    port     = "${var.target_port > 0 ? var.target_port : 9999 }" // note, not target3_port
    interval = 10
    healthy_threshold = 2
    unhealthy_threshold = 2
  }
  stickiness { type = "lb_cookie" }
}


#### 

#### NLB - works at the TCP level, such as for ssh connections

# listener - specifies how load balancer takes incoming traffic

resource "aws_lb_listener" "nlb" {
  count = "${ var.nlb_port>0 ? 1 : 0 }"
  load_balancer_arn = "${aws_lb.nlb.id}"
  port = "${var.nlb_port}"
  protocol = "TCP"
  default_action {
    type = "forward" 
    target_group_arn = "${aws_lb_target_group.nlb.id}"
  }
}


# load balancer - routes traffic across available targets

resource "aws_lb" "nlb" {
  count = "${ var.nlb_port>0 ? 1 : 0 }"
  name = "${var.prefix}-${var.appname}-${var.envname}-nlb"
  tags {
    Name = "${var.prefix}-${var.appname}-${var.envname}"
    Application = "${var.prefix}-${var.appname}-${var.envname}"
    KubernetesCluster = "${var.prefix}-${var.appname}-${var.envname}"
    Department = "${var.prefix}"
  }
  load_balancer_type = "network"
  internal = "true"
  subnets = [ "${var.subnet1a}", "${var.subnet1b}" ]
  enable_cross_zone_load_balancing = "true"
}


# output parameter with load balancer's dns name

resource "aws_ssm_parameter" "nlbdns" {
  count = "${ var.nlb_port>0 ? 1 : 0 }"
  name  = "/${var.prefix}/${var.envname}/${var.appname}/nlb/dnsname"
  type  = "String"
  value = "${aws_lb.nlb.dns_name}"
  overwrite = "true"
}

# add load balancer to route53 zone
resource "aws_route53_record" "nlb" {
  count = "${ var.nlb_port>0 ? 1 : 0 }"
  zone_id = "${data.aws_route53_zone.selected.zone_id}"
  name = "${var.prefix}-${var.appname}-${var.envname}-nlb"
  type = "A"
  alias {
    name = "${aws_lb.nlb.dns_name}"
    zone_id = "${aws_lb.nlb.zone_id}"
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "nlb_friendly" {
  count = "${(var.nlb_port > 0 && var.dnsname_nlb != "none") ? 1 : 0}"
  zone_id = "${data.aws_route53_zone.selected.zone_id}"
  name = "${var.dnsname_nlb}"
  type = "A"
  alias {
    name = "${aws_lb.nlb.dns_name}"
    zone_id = "${aws_lb.nlb.zone_id}"
    evaluate_target_health = false
  }
}

# target group - load balancer routes traffic to it, autoscaling group adds instances to it
resource "aws_lb_target_group" "nlb" {
  name_prefix = "${substr(var.envname,0,3)}${substr(var.appname,0,3)}"
  tags { name = "${var.prefix}-${var.appname}-${var.envname}" }
  port = "${ var.nlb_port > 0 ? var.nlb_port : 9999 }" 
  protocol = "TCP"
  vpc_id = "${var.vpc}"
  lifecycle { create_before_destroy = true }
}



