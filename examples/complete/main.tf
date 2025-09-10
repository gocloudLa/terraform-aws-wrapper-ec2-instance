module "wrapper_ec2_instance" {
  source = "../../"

  metadata = local.metadata
  project  = local.project

  ec2_instance_parameters = {

    "ec2_complete" = {

      # name = example""
      # ignore_ami_changes = true

      ami               = data.aws_ami.amazon_linux.id
      instance_type     = "t2.small" # used to set core count below
      availability_zone = data.aws_availability_zones.available.names[0]
      subnet_id         = data.aws_subnets.private.ids[0]
      create_eip        = true
      disable_api_stop  = false

      create_security_group = true
      security_group_ingress_rules = {
        "http" = {
          cidr_ipv4   = "0.0.0.0/0"
          from_port   = 80
          ip_protocol = "tcp"
          to_port     = 80
        }
      }

      create_iam_instance_profile = true
      iam_role_description        = "IAM role for EC2 instance"
      iam_role_policies = {
        AdministratorAccess = "arn:aws:iam::aws:policy/AdministratorAccess"
      }

      # only one of these can be enabled at a time
      hibernation = true
      # enclave_options_enabled = true

      user_data_base64            = base64encode(local.user_data)
      user_data_replace_on_change = false

      ## Needs to match the instance tipe used
      # cpu_options = {
      #   core_count       = 2
      #   threads_per_core = 1
      # }
      enable_volume_tags = false
      root_block_device = {
        encrypted  = true
        type       = "gp3"
        throughput = 200
        size       = 50
        tags = {
          Name = "my-root-block"
        }
      }

      ebs_volumes = {
        "/dev/sdf" = {
          size       = 5
          throughput = 200
          encrypted  = true
          # kms_key_id = KMS_KEY_ARN
          tags = {
            MountPoint = "/mnt/data"
          }
        }
      }

      tags = local.common_tags
    }

    # "ec2-session-manager" = {

    #   subnet_id = data.aws_subnets.private.ids[0]

    #   create_iam_instance_profile = true
    #   iam_role_description        = "IAM role for EC2 instance"
    #   iam_role_policies = {
    #     AmazonSSMManagedInstanceCore = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
    #   }

    #   tags = local.common_tags
    # }
    # "ec2_t2_unlimited" = {

    #   instance_type               = "t2.micro"
    #   cpu_credits                 = "unlimited"
    #   subnet_id              = data.aws_subnets.private.ids[0]
    #   associate_public_ip_address = true

    #   maintenance_options = {
    #     auto_recovery = "default"
    #   }

    #   tags = local.common_tags
    # }

    # "ec2_spot_instance" = {

    #   create_spot_instance = true

    #   availability_zone      = data.aws_availability_zones.available.names[0]
    #   subnet_id              = data.aws_subnets.private.ids[0]
    #   create_security_group = true
    #   security_group_ingress_rules ={
    #     "http" = {
    #       cidr_ipv4   = "0.0.0.0/0"
    #       from_port   = 80
    #       ip_protocol = "tcp"
    #       to_port     = 80
    #     }
    #   }
    #   associate_public_ip_address = true

    #   # Spot request specific attributes
    #   spot_price                = "0.1"
    #   spot_wait_for_fulfillment = true
    #   spot_type                 = "persistent"
    #   # End spot request specific attributes

    #   user_data_base64 = base64encode(local.user_data)

    #   cpu_options = {
    #     core_count       = 2
    #     threads_per_core = 1
    #   }

    #   enable_volume_tags = false
    #   root_block_device = {
    #     encrypted  = true
    #     type       = "gp3"
    #     throughput = 200
    #     size       = 50
    #     tags = {
    #       Name = "my-root-block"
    #     }
    #   }

    #   ebs_volumes = {
    #     "/dev/sdf" = {
    #       size       = 5
    #       throughput = 200
    #       encrypted  = true
    #       # kms_key_id  = aws_kms_key.this.arn # you must grant the AWSServiceRoleForEC2Spot service-linked role access to any custom KMS keys
    #     }
    #   }

    #   tags = local.common_tags
    # }
  }

  ec2_instance_defaults = var.ec2_instance_defaults
}