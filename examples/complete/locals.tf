locals {

  # VPC Name
  vpc_name = local.common_name_prefix

  user_data = <<-EOT
    #!/bin/bash
    echo "Hello Terraform!"
  EOT

}