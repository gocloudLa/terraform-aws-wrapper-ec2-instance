# output "wraper_ec2_instance" {
#   value = module.ec2_instance
# }

output "ec2_ssh_key_parameter_names" {
  value = { for k, v in aws_ssm_parameter.private_key : k => v.name }
}