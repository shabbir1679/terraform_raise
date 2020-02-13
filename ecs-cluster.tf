# see inputs.tf for configurable variables


# ECS cluster

resource "aws_ecs_cluster" "app" {
  count = "${var.ecscluster}"
  name = "${var.prefix}-${var.appname}-${var.envname}"

}


