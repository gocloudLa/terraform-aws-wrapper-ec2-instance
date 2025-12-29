locals {

  enable_security_group = alltrue([
    for _, value in var.ec2_instance_parameters :
    value.create_security_group 
  ]) ? 1 : 0
}