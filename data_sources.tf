data "aws_region" "current" {}

data "aws_caller_identity" "current" {}

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
    Name = try(each.value.subnet_name, local.default_subnet_private_name)
  }
}

data "aws_subnet" "this" {
  for_each = data.aws_subnets.this

  id = data.aws_subnets.this[each.key].ids[0]
}


data "aws_security_group" "default" {
  for_each = var.ec2_instance_parameters

  vpc_id = data.aws_vpc.this[each.key].id

  tags = {
    Name = local.default_security_group
  }
}

data "aws_ami" "ami_id" {
  for_each = var.ec2_instance_parameters

  most_recent = true
  owners      = try(each.value.owners, var.ec2_instance_defaults.owners, ["amazon"])

  dynamic "filter" {
    for_each = try(each.value.ami_filter, {
      name = ["al2023-ami-*-x86_64"]
    })
    content {
      name   = filter.key
      values = filter.value
    }
  }
}
