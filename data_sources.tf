data "aws_region" "current" {}

data "aws_caller_identity" "current" {}

data "aws_availability_zones" "available" {
  state = "available"
}

data "aws_vpc" "this" {
  for_each = var.ec2_instance_parameters
  filter {
    name = "tag:Name"
    values = [
      try(each.value.vpc_name, local.default_vpc_name)
    ]
  }
}

data "aws_subnets" "this" {
  for_each = var.ec2_instance_parameters
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.this[each.key].id]
  }

  tags = {
    Name = try(each.value.subnet_name, local.default_subnet_name)
  }
}

data "aws_security_group" "default" {
  for_each = var.ec2_instance_parameters

  vpc_id = data.aws_vpc.this[each.key].id

  tags = {
    Name = "${local.common_name_prefix}-default"
  }
}
