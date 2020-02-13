# common to all our apps
variable "prefix"        { default = "ditools" }
variable "s3bucket"      { default = "tools-data-toolstsyspropenterprise-us-east-1-tsys" }
variable "scriptspath"   { default = "scripts" }
variable "keyname"       { default = "g5apps" }
variable "baseami"       { default = "tsys-alin-hvm-ebs-enc-*" }
variable "profile"       { default = "Node-Profile" }

# deploy to this VPC
variable "vpc"      { default = "vpc-07168ba8ef308a684" }

# use these subnets in our availability zones
variable "subnet1a" { default = "subnet-02dc98b8c27929e9d" }
variable "subnet1b" { default = "subnet-02cc8af28c07908cb" }

