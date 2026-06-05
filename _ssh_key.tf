locals {
  ssh_key_parameters = {
    for ec2_instance_key, ec2_instance_config in var.ec2_instance_parameters :
    ec2_instance_key => {
      create                   = try(ec2_instance_config.create_key, true)
      create_private_key       = try(ec2_instance_config.create_private_key, false)
      key_name                 = try(ec2_instance_config.key_name, "${local.common_name}-${ec2_instance_key}")
      key_name_prefix          = try(ec2_instance_config.key_name_prefix, null)
      private_key_algorithm    = try(ec2_instance_config.private_key_algorithm, "RSA")
      private_key_rsa_bits     = try(ec2_instance_config.private_key_rsa_bits, 4096)
      private_key_wo_version   = tostring(try(ec2_instance_config.private_key_wo_version, var.ec2_instance_defaults.private_key_wo_version, 1))
      public_key               = try(ec2_instance_config.public_key, "")
      store_public_key         = try(ec2_instance_config.store_public_key, var.ec2_instance_defaults.store_public_key, false)
      tags                     = merge(local.default_common_tags, try(ec2_instance_config.tags, var.ec2_instance_defaults, null), { Name = try(ec2_instance_config.key_name, "${local.common_name}-${ec2_instance_key}-key") })
    } if try(ec2_instance_config.create_key, false)
  }

  ssh_key_generated_public_keys = {
    for k, v in ephemeral.tls_private_key.this :
    k => trimspace(v.public_key_openssh)
  }
}

ephemeral "tls_private_key" "this" {
  for_each = {
    for k, v in local.ssh_key_parameters : k => v
    if v.create_private_key
  }

  algorithm = each.value.private_key_algorithm
  rsa_bits  = each.value.private_key_rsa_bits
}

resource "aws_ssm_parameter" "private_key" {
  for_each = {
    for k, v in local.ssh_key_parameters : k => v
    if v.create_private_key
  }

  name             = "/KEY_PAIR/${local.common_name}-${each.key}"
  type             = "SecureString"
  value_wo         = trimspace(ephemeral.tls_private_key.this[each.key].private_key_pem)
  value_wo_version = each.value.private_key_wo_version

  tags = each.value.tags
}

resource "aws_ssm_parameter" "public_key" {
  for_each = {
    for k, v in local.ssh_key_parameters : k => v
    if v.create_private_key && v.store_public_key
  }

  name             = "/KEY_PAIR/${local.common_name}-${each.key}/public"
  type             = "String"
  value_wo         = trimspace(ephemeral.tls_private_key.this[each.key].public_key_openssh)
  value_wo_version = each.value.private_key_wo_version

  tags = each.value.tags
}

data "aws_ssm_parameter" "public_key" {
  for_each = {
    for k, v in local.ssh_key_parameters : k => v
    if v.create_private_key && v.store_public_key
  }

  name       = aws_ssm_parameter.public_key[each.key].name
  depends_on = [aws_ssm_parameter.public_key]
}

resource "aws_key_pair" "this" {
  for_each = local.ssh_key_parameters

  key_name        = each.value.key_name
  key_name_prefix = each.value.key_name_prefix
  public_key = (
    each.value.create_private_key
    ? (
      each.value.store_public_key
      ? trimspace(data.aws_ssm_parameter.public_key[each.key].value)
      : local.ssh_key_generated_public_keys[each.key]
    )
    : each.value.public_key
  )

  tags = each.value.tags
}
