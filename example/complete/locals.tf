locals {

  metadata = {
    aws_region  = "us-east-1"
    aws_secondary_region = "us-east-2"
    environment = "Production"

    public_domain  = "democorp.cloud"
    private_domain = "democorp"

    key = {
      company = "gcl"
      region  = "use1"
      env     = "l01"
    }
  }

  project = "example"

  common_name_prefix = join("-", [
    local.metadata.key.company,
    local.metadata.key.env
  ])

  common_name = join("-", [
    local.common_name_prefix,
    local.project
  ])

  common_tags = {
    "company"     = local.metadata.key.company
    "provisioner" = "terraform"
    "environment" = local.metadata.environment
    "project"     = local.project
    "created-by"  = "GoCloud.la"
  }

  # VPC Name
  vpc_name = local.common_name_prefix

  user_data = <<-EOT
    #!/bin/bash
    echo "Hello Terraform!"
  EOT

}