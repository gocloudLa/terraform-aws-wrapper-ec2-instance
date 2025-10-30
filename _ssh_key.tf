locals {
  ssh_key_parameters_tmp = [
    for ec2_instance_key, ec2_instance_config in var.ec2_instance_parameters :
    {
      "${ec2_instance_key}" = {
        create                = try(ec2_instance_config.create_ssh_key, true)
        create_private_key    = try(ec2_instance_config.create_private_key, false)
        key_name              = try(ec2_instance_config.key_name, "${local.common_name}-${ec2_instance_key}")
        key_name_prefix       = try(ec2_instance_config.key_name_prefix, null)
        private_key_algorithm = try(ec2_instance_config.private_key_algorithm, "RSA")
        private_key_rsa_bits  = try(ec2_instance_config.private_key_rsa_bits, 4096)
        public_key            = sensitive(try(ec2_instance_config.public_key, ""))
        tags                  = merge(lookup(ec2_instance_config, "tags", local.default_common_tags), { Name = "${local.common_name}-${ec2_instance_key}-key" })
      }
    } if try(ec2_instance_config.create_key, false)
  ]
  ssh_key_parameters = merge(flatten(local.ssh_key_parameters_tmp)...)
}

module "key-pair" {
  source  = "terraform-aws-modules/key-pair/aws"
  version = "2.1.0"

  for_each = local.ssh_key_parameters

  create                = each.value.create
  create_private_key    = each.value.create_private_key
  key_name              = each.value.key_name
  key_name_prefix       = each.value.key_name_prefix
  private_key_algorithm = each.value.private_key_algorithm
  private_key_rsa_bits  = each.value.private_key_rsa_bits
  public_key            = each.value.public_key
  tags                  = each.value.tags
}

resource "aws_ssm_parameter" "this" {
  for_each = {
    for k, v in local.ssh_key_parameters : k => v
    if v.create_private_key
  }

  name  = "/KEY_PAIR/${local.common_name}-${each.key}"
  type  = "SecureString"
  value = sensitive(module.key-pair[each.key].private_key_pem)
}