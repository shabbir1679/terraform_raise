
/* use a static security group for all purposes */

data "aws_security_group" "static" { name = "ditools-static" }

output "defsec" { value = "${data.aws_security_group.static.id}" }
output "albsec" { value = "${data.aws_security_group.static.id}" }
output "nlbsec" { value = "${data.aws_security_group.static.id}" }
output "appsec" { value = "${data.aws_security_group.static.id}" }
output "efssec" { value = "${data.aws_security_group.static.id}" }
output "rdssec" { value = "${data.aws_security_group.static.id}" }
output "essec"  { value = "${data.aws_security_group.static.id}" }





/* to dynamically create security groups for each purpose, 
      comment out all of the above, and uncomment all of the below
*/


/* 

# load balancers 
output "albsec" { value = "${aws_security_group.albsec.id}" }
resource "aws_security_group" "albsec" {
  name_prefix = "albsec"
  vpc_id      = "${var.vpc}"
  ingress {
    from_port   = "${var.listen_port}"
    to_port     = "${var.listen_port}"
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/8"]
  }
  egress {
    from_port       = 0
    to_port         = 65535
    protocol        = "tcp"
    cidr_blocks     = ["0.0.0.0/0"]
  }
}


output "nlbsec" { value = "${aws_security_group.nlbsec.id}" }
resource "aws_security_group" "nlbsec" {
  name_prefix = "nlbsec"
  vpc_id      = "${var.vpc}"
  ingress {
    from_port   = "${var.nlb_port}"
    to_port     = "${var.nlb_port}"
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/8"]
  }
  egress {
    from_port       = 0
    to_port         = 65535
    protocol        = "tcp"
    cidr_blocks     = ["0.0.0.0/0"]
  }
}

# application servers
output "appsec" { value = "${aws_security_group.appsec.id}" }
resource "aws_security_group" "appsec" {
  name_prefix = "appsec"
  vpc_id      = "${var.vpc}"

  # application service
  ingress {
    from_port   = "${var.target_port}"
    to_port     = "${var.target_port}"
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/8"]
  }

  ingress {
    from_port   = "${var.nlb_port}"
    to_port     = "${var.nlb_port}"
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

  # cluster interconnect and cache rmi
  ingress {
    from_port   = "${var.inter_port}"
    to_port     = "${var.inter_port}"
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/8"]
  }

  # cluster interconnect and cache rmi
  ingress {
    from_port   = "${var.from_port}"
    to_port     = "${var.to_port}"
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/8"]
  }

  # cluster interconnect and cache rmi
  ingress {
    from_port   = "${var.udp_port}"
    to_port     = "${var.udp_port}"
    protocol    = "udp"
    cidr_blocks = ["10.0.0.0/8"]
  }

  egress {
    from_port       = 0
    to_port         = 65535
    protocol        = "tcp"
    cidr_blocks     = ["0.0.0.0/0"]
  }

  egress {
    from_port       = 0
    to_port         = 65535
    protocol        = "udp"
    cidr_blocks     = ["0.0.0.0/0"]
  }

}


# shared filesytem mountpoints
output "efssec" { value = "${aws_security_group.efssec.id}" }
resource "aws_security_group" "efssec" {
  name_prefix = "efssec"
  vpc_id      = "${var.vpc}"
  ingress {
    from_port   = 2049
    to_port     = 2049
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/8"]
  }
  egress {
    from_port       = 0
    to_port         = 65535
    protocol        = "tcp"
    cidr_blocks     = ["0.0.0.0/0"]
  }
}


# databases
output "rdssec" { value = "${aws_security_group.rdssec.id}" }
resource "aws_security_group" "rdssec" {
  name_prefix = "rdssec"
  vpc_id      = "${var.vpc}"
  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/8"]
  }
  egress {
    from_port       = 0
    to_port         = 65535
    protocol        = "tcp"
    cidr_blocks     = ["0.0.0.0/0"]
  }
}


# elasticsearch
output "essec" { value = "${aws_security_group.essec.id}" }
resource "aws_security_group" "essec" {
  name_prefix = "essec"
  vpc_id      = "${var.vpc}"

  // only if we needed to allow http instead of https access
  // ingress {
  //   from_port   = 9200
  //   to_port     = 9200
  //   protocol    = "tcp"
  //   cidr_blocks = ["10.0.0.0/8"]
  // }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/8"]
  }

  egress {
    from_port       = 0
    to_port         = 65535
    protocol        = "tcp"
    cidr_blocks     = ["0.0.0.0/0"]
  }
}

*/
