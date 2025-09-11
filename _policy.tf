locals {
  custom_policy_parameters_tmp = [
    for ec2_instance_key, ec2_instance_config in var.ec2_instance_parameters :
    {
      "${ec2_instance_key}" = {
        create        = try(ec2_instance_config.create_custom_policy, false)
        custom_policy = try(ec2_instance_config.custom_policy, "")
        tags          = merge(lookup(ec2_instance_config, "tags", local.common_tags), { Name = "${local.common_name}-${ec2_instance_key}-policy" })
      }
    } if try(ec2_instance_config.create_custom_policy, false)
  ]
  custom_policy_parameters = merge(flatten(local.custom_policy_parameters_tmp)...)
}

resource "aws_iam_policy" "this" {
  for_each = local.custom_policy_parameters

  name   = "${local.common_name}-${each.key}-policy"
  policy = each.value.custom_policy.json
  tags   = each.value.tags
}

