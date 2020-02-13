# find the latest tsys AMI
data "aws_ami" "baseami" {
  most_recent = true
  owners = ["self", "amazon"]
  filter {
    name   = "image-id"

    values = ["ami-0de53d8956e8dcf80"]   # Amazon's base ALIN2
    # values = ["ami-0922553b7b0369273"] # Amazon's base ALIN2
    # values = ["${var.baseami}"]       # if we want to use different ones for different apps

  }
}


data "aws_ami" "eksami" {
  most_recent = true
  owners = ["self", "amazon"]
  filter {
    name   = "image-id"

    values = ["ami-009d6802948d06e52"]   # Amazon's base ALIN2
#    values = ["ami-0a0b913ef3249b655"] # Amazon's EKS-Optimized AMI
    # values = ["${var.eksami}"]       # if we want to use different ones for different apps

  }
}


data "aws_ami" "ecsami" {
  most_recent = true
  owners = ["self", "amazon"]
  filter {
    name   = "image-id"

    values = ["ami-045f1b3f87ed83659"] # Amazon's ECS-Optimized AMI
    # values = ["${var.ecsami}"]       # if we want to use different ones for different apps

  }
}


