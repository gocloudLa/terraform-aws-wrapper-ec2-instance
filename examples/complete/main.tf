module "wrapper_ec2_instance" {
  source = "../../"

  metadata = local.metadata

  ec2_instance_parameters = {
    # "ExSimple" = {
    #   # ubuntu AMI
    #   ami           = "ami-0360c520857e3138f"
    #   ami_filter    = { name = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-*"]}

    #   instance_type = "t3.micro"

    #   vpc_id        = "vpc-XXXXXXXXXXXXXXXXX"

    #   vpc_name      = "${local.common_name_prefix}"
    #   subnet_id     = "subnet-XXXXXXXXXXXXXXXXX"
    #   subnet_name   = "${local.common_name_prefix}-private-us-east-1a"
    # }
    # "ExComplete" = {

    #   # name = "example"
    #   # ignore_ami_changes = true

    #   ami_filter = {
    #     name = ["al2023-ami-*-x86_64"]
    #   }
    #   instance_type = "t2.small" # used to set core count below
    #   # availability_zone = data.aws_availability_zones.available.names[1]
    #   subnet_name      = "${local.common_name_prefix}-private-us-east-1a"
    #   create_eip       = true
    #   disable_api_stop = false

    #   create_security_group = true
    #   security_group_ingress_rules = {
    #     "http" = {
    #       cidr_ipv4   = "0.0.0.0/0"
    #       from_port   = 80
    #       ip_protocol = "tcp"
    #       to_port     = 80
    #     }
    #     # "ssh" = {
    #     #   cidr_ipv4   = "MY_IP"
    #     #   from_port   = 22
    #     #   ip_protocol = "tcp"
    #     #   to_port     = 22
    #     # }
    #   }
    #   # vpc_security_group_ids = ["sg-xxxxxxxxxxxxxxxxx"]

    #   create_key                  = true
    #   create_private_key          = true
    #   create_custom_policy        = true
    #   create_iam_instance_profile = true
    #   custom_policy               = data.aws_iam_policy_document.example_policy
    #   iam_role_description        = "IAM role for EC2 instance"
    #   iam_role_policies = {
    #     AdministratorAccess = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
    #   }

    #   # only one of these can be enabled at a time
    #   hibernation = true
    #   # enclave_options_enabled = true

    #   user_data_base64            = base64encode(local.user_data)
    #   user_data_replace_on_change = false

    #   ## Needs to match the instance tipe used
    #   # cpu_options = {
    #   #   core_count       = 2
    #   #   threads_per_core = 1
    #   # }
    #   enable_volume_tags = false
    #   root_block_device = {
    #     encrypted  = true
    #     type       = "gp3"
    #     throughput = 200
    #     size       = 30
    #     tags = {
    #       Name = "my-root-block"
    #     }
    #   }

    #   ebs_volumes = {
    #     "/dev/sdf" = {
    #       size       = 5
    #       throughput = 200
    #       encrypted  = true
    #       # kms_key_id = KMS_KEY_ARN
    #       tags = {
    #         MountPoint = "/mnt/data"
    #       }
    #     }
    #   }
    # }
    # "exT2Unlimited" = {

    #   instance_type               = "t2.micro"
    #   cpu_credits                 = "unlimited"
    #   subnet_name                 = "${local.common_name_prefix}-private-us-east-1a"
    #   associate_public_ip_address = true

    #   maintenance_options = {
    #     auto_recovery = "default"
    #   }
    # }

    # "ec2_spot_instance" = {

    #   create_spot_instance = true

    #   availability_zone     = "use1-az2"
    #   subnet_name           = "${local.common_name_prefix}-private-us-east-1a"
    #   create_security_group = true
    #   security_group_ingress_rules = {
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
    # }
  }

  ec2_instance_defaults = var.ec2_instance_defaults
}