locals {

  metadata = {
    aws_region     = "us-east-1"
    environment    = "Production"
    project        = "Example"
    public_domain  = "democorp.cloud"
    private_domain = "democorp"

    key = {
      company = "gcl"
      region  = "use1"
      env     = "l01"
      project = "example"
      layer   = "workload"
    }
  }

  common_name_prefix = join("-", [
    local.metadata.key.company,
    local.metadata.key.env
  ])

  common_name = join("-", [
    local.common_name_prefix,
    local.metadata.key.project
  ])
}