# Standard Platform - Terraform Module 🚀🚀
<p align="right"><a href="https://partners.amazonaws.com/partners/0018a00001hHve4AAC/GoCloud"><img src="https://img.shields.io/badge/AWS%20Partner-Advanced-orange?style=for-the-badge&logo=amazonaws&logoColor=white" alt="AWS Partner"/></a><a href="LICENSE"><img src="https://img.shields.io/badge/License-Apache%202.0-green?style=for-the-badge&logo=apache&logoColor=white" alt="LICENSE"/></a></p>

Welcome to the Standard Platform — a suite of reusable and production-ready Terraform modules purpose-built for AWS environments.
Each module encapsulates best practices, security configurations, and sensible defaults to simplify and standardize infrastructure provisioning across projects.

## 📦 Module: Terraform EC2 Instance Module
<p align="right"><a href="https://github.com/gocloudLa/terraform-aws-wrapper-ec2-instance/releases/latest"><img src="https://img.shields.io/github/v/release/gocloudLa/terraform-aws-wrapper-ec2-instance.svg?style=for-the-badge" alt="Latest Release"/></a><a href=""><img src="https://img.shields.io/github/last-commit/gocloudLa/terraform-aws-wrapper-ec2-instance.svg?style=for-the-badge" alt="Last Commit"/></a><a href="https://registry.terraform.io/modules/gocloudLa/wrapper-ec2-instance/aws"><img src="https://img.shields.io/badge/Terraform-Registry-7B42BC?style=for-the-badge&logo=terraform&logoColor=white" alt="Terraform Registry"/></a></p>
The Terraform wrapper for AWS EC2 Instance simplifies the management and deployment of EC2 instances in Amazon Web Services. This wrapper functions as a standardized template that abstracts technical complexity and allows creating multiple reusable EC2 instances.

### ✨ Features

- 🖥️ [Standard EC2 Instances](#standard-ec2-instances) - Complete configuration of CPU, memory and storage for standard EC2 instances

- 💰 [Spot Instances](#spot-instances) - Cost-effective instances for fault-tolerant workloads with reduced pricing

- 🔒 [Security Groups & IAM](#security-groups-&-iam) - Customizable ingress/egress rules and granular IAM roles and policies

- 💾 [EBS Volumes & Storage](#ebs-volumes-&-storage) - Additional EBS volumes with encryption and performance configuration

- 🔑 [SSH Key Pairs](#ssh-key-pairs) - Creates and manages SSH key pairs with private key storage in SSM Parameter Store

- 📋 [Custom IAM Policies](#custom-iam-policies) - Supports custom IAM policies for instances with automatic role attachment



### 🔗 External Modules
| Name | Version |
|------|------:|
| <a href="https://github.com/terraform-aws-modules/terraform-aws-ec2-instance" target="_blank">terraform-aws-modules/ec2-instance/aws</a> | 6.1.1 |
| <a href="https://github.com/terraform-aws-modules/terraform-aws-key-pair" target="_blank">terraform-aws-modules/key-pair/aws</a> | 2.1.0 |



## 🚀 Quick Start
```hcl
module "wrapper_ec2_instance" {
  source = "gocloudLa/wrapper-ec2-instance/aws"
  
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
  
  ec2_instance_parameters = {
    "ExComplete" = {
      ami_filter = {
        name = ["al2023-ami-*-x86_64"]
      }
      instance_type = "t2.small"
      subnet_name   = "${local.common_name_prefix}-private-us-east-1a"
      create_eip    = true
      
      create_security_group = true
      security_group_ingress_rules = {
        "http" = {
          cidr_ipv4   = "0.0.0.0/0"
          from_port   = 80
          ip_protocol = "tcp"
          to_port     = 80
        }
      }
      
      create_key                  = true
      create_private_key          = true
      create_custom_policy        = true
      create_iam_instance_profile = true
      iam_role_description        = "IAM role for EC2 instance"
      iam_role_policies = {
        SSMCore = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
      }
      
      hibernation = true
      user_data_base64 = base64encode(<<-EOT
        #!/bin/bash
        echo "Hello Terraform!"
      EOT
      )
      
      root_block_device = {
        encrypted  = true
        type       = "gp3"
        throughput = 200
        size       = 30
      }
      
      ebs_volumes = {
        "/dev/sdf" = {
          size       = 5
          throughput = 200
          encrypted  = true
        }
      }
    }
  }
}
```


## 🔧 Additional Features Usage

### Standard EC2 Instances
Deploy standard EC2 instances with complete configuration including CPU, memory, and storage options.
Supports various instance types from t3.micro to high-performance instances.


<details><summary>Simple Instance</summary>

```hcl
ec2_instance_parameters = {
  "ExSimple" = {
    # Basic configuration with minimal settings
    instance_type = "t3.micro"
    subnet_name   = "${local.common_name_prefix}-private-us-east-1a"
  }
}
```


</details>

<details><summary>T2 Unlimited Credits</summary>

```hcl
ec2_instance_parameters = {
  "exT2Unlimited" = {
    instance_type               = "t2.micro"
    cpu_credits                 = "unlimited"
    subnet_name                 = "${local.common_name_prefix}-private-us-east-1a"
    associate_public_ip_address = true
    
    maintenance_options = {
      auto_recovery = "default"
    }
  }
}
```


</details>


### Spot Instances
Deploy Spot instances for workloads tolerant to interruptions with significantly reduced pricing.
Configure spot price, interruption behavior, and launch groups for optimal cost savings.


<details><summary>Spot Instance Configuration</summary>

```hcl
ec2_instance_parameters = {
  "ec2_spot_instance" = {
    create_spot_instance = true
    
    availability_zone     = "use1-az2"
    subnet_name           = "${local.common_name_prefix}-private-us-east-1a"
    create_security_group = true
    security_group_ingress_rules = {
      "http" = {
        cidr_ipv4   = "0.0.0.0/0"
        from_port   = 80
        ip_protocol = "tcp"
        to_port     = 80
      }
    }
    associate_public_ip_address = true
    
    # Spot request specific attributes
    spot_price                = "0.1"
    spot_wait_for_fulfillment = true
    spot_type                 = "persistent"
    
    user_data_base64 = base64encode(<<-EOT
      #!/bin/bash
      echo "Hello Terraform!"
    EOT
    )
    
    cpu_options = {
      core_count       = 2
      threads_per_core = 1
    }
    
    root_block_device = {
      encrypted  = true
      type       = "gp3"
      throughput = 200
      size       = 50
    }
    
    ebs_volumes = {
      "/dev/sdf" = {
        size       = 5
        throughput = 200
        encrypted  = true
      }
    }
  }
}
```


</details>


### Security Groups & IAM
Create and manage Security Groups with customizable rules and IAM Instance Profiles with granular access policies.
Supports both custom security groups and existing ones, with comprehensive IAM role management.
When `create_security_group = true`, the created security group is automatically used by the instance. When `create_security_group = false` and `vpc_security_group_ids` is not provided, the default VPC security group is used.


<details><summary>Security Configuration</summary>

```hcl
ec2_instance_parameters = {
  "ExComplete" = {
    create_security_group = true
    security_group_ingress_rules = {
      "http" = {
        cidr_ipv4   = "0.0.0.0/0"
        from_port   = 80
        ip_protocol = "tcp"
        to_port     = 80
      }
    }
    
    create_key                  = true
    create_private_key          = true
    create_custom_policy        = true
    create_iam_instance_profile = true
    iam_role_description        = "IAM role for EC2 instance"
    iam_role_policies = {
      SSMCore = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
    }
  }
}
```


</details>


### EBS Volumes & Storage
Configure additional EBS volumes with encryption, performance optimization, and various storage types.
Supports gp3, io2, and other storage types with custom IOPS and throughput settings.


<details><summary>Storage Configuration</summary>

```hcl
ec2_instance_parameters = {
  "ExComplete" = {
    enable_volume_tags = false
    root_block_device = {
      encrypted  = true
      type       = "gp3"
      throughput = 200
      size       = 30
      tags = {
        Name = "my-root-block"
      }
    }
    
    ebs_volumes = {
      "/dev/sdf" = {
        size       = 5
        throughput = 200
        encrypted  = true
        tags = {
          MountPoint = "/mnt/data"
        }
      }
    }
  }
}
```


</details>


### SSH Key Pairs
Automatically create SSH key pairs for EC2 instances with secure private key storage in AWS Systems Manager Parameter Store.
Supports RSA and ED25519 algorithms with configurable key sizes and automatic key rotation.
When `create_key = true`, the created key pair is automatically used by the instance. To use an existing key pair, set `key_name` directly without setting `create_key`.


<details><summary>SSH Key Configuration</summary>

```hcl
ec2_instance_parameters = {
  "ExComplete" = {
    create_key         = true
    create_private_key = true
    # Private key will be stored in SSM Parameter Store at /KEY_PAIR/{common_name}-{instance_key}
    # The key is automatically used by the instance
  }
}
```


</details>

<details><summary>Use Existing SSH Key</summary>

```hcl
ec2_instance_parameters = {
  "ExComplete" = {
    key_name = "my-existing-key-pair"
    # Do not set create_key when using an existing key
  }
}
```


</details>


### Custom IAM Policies
Create and attach custom IAM policies to EC2 instances with automatic role integration.
Define custom permissions and policies that are automatically attached to the instance IAM role.


<details><summary>Custom Policy Configuration</summary>

```hcl
# Define custom policy in data source
data "aws_iam_policy_document" "example_policy" {
  statement {
    sid    = "ListBuckets"
    effect = "Allow"
    actions   = ["s3:ListAllMyBuckets"]
    resources = ["*"]
  }
  
  statement {
    effect = "Allow"
    actions = [
      "s3:ListBucket",
      "s3:GetBucketLocation"
    ]
    resources = ["arn:aws:s3:::/example"]
  }
}

# Use in EC2 instance configuration
ec2_instance_parameters = {
  "ExComplete" = {
    create_custom_policy        = true
    create_iam_instance_profile = true
    custom_policy               = data.aws_iam_policy_document.example_policy
  }
}
```


</details>




## 📑 Inputs
| Name                                 | Description                                                                                                                                                                                                                      | Type                | Default                                                                                                                                                                                   | Required |
| ------------------------------------ | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | -------- |
| ami                                  | ID of the AMI to use                                                                                                                                                                                                             | `string`            | `null`                                                                                                                                                                                    | no       |
| ami_filter                           | Filter to find AMI by name                                                                                                                                                                                                       | `map(list(string))` | `{name = ["al2023-ami-*-x86_64"]}`                                                                                                                                                        | no       |
| ami_ssm_parameter                    | SSM parameter to get AMI                                                                                                                                                                                                         | `string`            | `null`                                                                                                                                                                                    | no       |
| associate_public_ip_address          | Assign public IP automatically                                                                                                                                                                                                   | `bool`              | `null`                                                                                                                                                                                    | no       |
| availability_zone                    | Availability zone                                                                                                                                                                                                                | `string`            | `null`                                                                                                                                                                                    | no       |
| capacity_reservation_specification   | Capacity reservation specification                                                                                                                                                                                               | `object`            | `null`                                                                                                                                                                                    | no       |
| cpu_credits                          | CPU credits mode for T instances                                                                                                                                                                                                 | `string`            | `null`                                                                                                                                                                                    | no       |
| cpu_options                          | CPU options for the instance                                                                                                                                                                                                     | `object`            | `null`                                                                                                                                                                                    | no       |
| create                               | Whether to create the instance                                                                                                                                                                                                   | `bool`              | `true`                                                                                                                                                                                    | no       |
| create_custom_policy                 | Create custom IAM policy                                                                                                                                                                                                         | `bool`              | `false`                                                                                                                                                                                   | no       |
| create_eip                           | Create Elastic IP                                                                                                                                                                                                                | `bool`              | `false`                                                                                                                                                                                   | no       |
| create_iam_instance_profile          | Create IAM Instance Profile                                                                                                                                                                                                      | `bool`              | `true`                                                                                                                                                                                    | no       |
| create_key                           | Create SSH key pair                                                                                                                                                                                                              | `bool`              | `false`                                                                                                                                                                                   | no       |
| create_private_key                   | Create private key and store it in SSM                                                                                                                                                                                           | `bool`              | `false`                                                                                                                                                                                   | no       |
| create_security_group                | Create Security Group                                                                                                                                                                                                            | `bool`              | `false`                                                                                                                                                                                   | no       |
| create_spot_instance                 | Create spot instance                                                                                                                                                                                                             | `bool`              | `false`                                                                                                                                                                                   | no       |
| custom_policy                        | Custom IAM policy document                                                                                                                                                                                                       | `string`            | `null`                                                                                                                                                                                    | no       |
| disable_api_stop                     | Disable stop via API                                                                                                                                                                                                             | `bool`              | `null`                                                                                                                                                                                    | no       |
| disable_api_termination              | Disable API termination                                                                                                                                                                                                          | `bool`              | `null`                                                                                                                                                                                    | no       |
| ebs_optimized                        | Enable EBS optimization                                                                                                                                                                                                          | `bool`              | `null`                                                                                                                                                                                    | no       |
| ebs_volumes                          | Additional EBS volumes                                                                                                                                                                                                           | `map(object)`       | `null`                                                                                                                                                                                    | no       |
| eip_domain                           | Domain for EIP                                                                                                                                                                                                                   | `string`            | `vpc`                                                                                                                                                                                     | no       |
| eip_tags                             | Tags for EIP                                                                                                                                                                                                                     | `map(string)`       | `{}`                                                                                                                                                                                      | no       |
| enable_primary_ipv6                  | Enable primary IPv6                                                                                                                                                                                                              | `bool`              | `null`                                                                                                                                                                                    | no       |
| enable_volume_tags                   | Enable volume tags                                                                                                                                                                                                               | `bool`              | `true`                                                                                                                                                                                    | no       |
| enclave_options_enabled              | Enable enclave options                                                                                                                                                                                                           | `bool`              | `null`                                                                                                                                                                                    | no       |
| ephemeral_block_device               | Ephemeral block device configuration                                                                                                                                                                                             | `list(object)`      | `null`                                                                                                                                                                                    | no       |
| get_password_data                    | Get password data                                                                                                                                                                                                                | `bool`              | `null`                                                                                                                                                                                    | no       |
| hibernation                          | Enable hibernation                                                                                                                                                                                                               | `bool`              | `null`                                                                                                                                                                                    | no       |
| host_id                              | Host ID for dedicated host                                                                                                                                                                                                       | `string`            | `null`                                                                                                                                                                                    | no       |
| host_resource_group_arn              | Host resource group ARN                                                                                                                                                                                                          | `string`            | `null`                                                                                                                                                                                    | no       |
| iam_instance_profile                 | IAM instance profile name                                                                                                                                                                                                        | `string`            | `null`                                                                                                                                                                                    | no       |
| iam_role_description                 | Description for IAM role                                                                                                                                                                                                         | `string`            | `null`                                                                                                                                                                                    | no       |
| iam_role_name                        | Name for IAM role                                                                                                                                                                                                                | `string`            | `null`                                                                                                                                                                                    | no       |
| iam_role_path                        | Path for IAM role                                                                                                                                                                                                                | `string`            | `null`                                                                                                                                                                                    | no       |
| iam_role_permissions_boundary        | Permissions boundary for IAM role                                                                                                                                                                                                | `string`            | `null`                                                                                                                                                                                    | no       |
| iam_role_policies                    | IAM policies to attach                                                                                                                                                                                                           | `map(string)`       | `{SSMCore = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"}`                                                                                                                      | no       |
| iam_role_tags                        | Tags for IAM role                                                                                                                                                                                                                | `map(string)`       | `{}`                                                                                                                                                                                      | no       |
| iam_role_use_name_prefix             | Use name prefix for IAM role                                                                                                                                                                                                     | `bool`              | `true`                                                                                                                                                                                    | no       |
| ignore_ami_changes                   | Ignore AMI changes                                                                                                                                                                                                               | `bool`              | `true`                                                                                                                                                                                    | no       |
| instance_initiated_shutdown_behavior | Instance initiated shutdown behavior                                                                                                                                                                                             | `string`            | `null`                                                                                                                                                                                    | no       |
| instance_market_options              | Instance market options                                                                                                                                                                                                          | `object`            | `null`                                                                                                                                                                                    | no       |
| instance_tags                        | Tags for instance                                                                                                                                                                                                                | `map(string)`       | `{}`                                                                                                                                                                                      | no       |
| instance_type                        | Type of EC2 instance                                                                                                                                                                                                             | `string`            | `t3.micro`                                                                                                                                                                                | no       |
| ipv6_address_count                   | Number of IPv6 addresses                                                                                                                                                                                                         | `number`            | `null`                                                                                                                                                                                    | no       |
| ipv6_addresses                       | List of IPv6 addresses                                                                                                                                                                                                           | `list(string)`      | `null`                                                                                                                                                                                    | no       |
| key_name                             | Name of the Key Pair                                                                                                                                                                                                             | `string`            | `null`                                                                                                                                                                                    | no       |
| key_name_prefix                      | Prefix for generated key name                                                                                                                                                                                                    | `string`            | `null`                                                                                                                                                                                    | no       |
| launch_template                      | Launch template configuration                                                                                                                                                                                                    | `object`            | `null`                                                                                                                                                                                    | no       |
| maintenance_options                  | Maintenance options                                                                                                                                                                                                              | `object`            | `null`                                                                                                                                                                                    | no       |
| metadata                             | Metadata configuration for naming and tagging                                                                                                                                                                                    | `any`               | `null`                                                                                                                                                                                    | yes      |
| metadata_options                     | Instance metadata options                                                                                                                                                                                                        | `object`            | `{http_endpoint="enabled", http_put_response_hop_limit=1, http_tokens="required"}`                                                                                                        | no       |
| monitoring                           | Enable detailed monitoring                                                                                                                                                                                                       | `bool`              | `null`                                                                                                                                                                                    | no       |
| name                                 | Name of the instance                                                                                                                                                                                                             | `string`            | `null`                                                                                                                                                                                    | no       |
| network_interface                    | Network interface configuration                                                                                                                                                                                                  | `list(object)`      | `null`                                                                                                                                                                                    | no       |
| owners                               | AMI owners filter                                                                                                                                                                                                                | `list(string)`      | `["amazon"]`                                                                                                                                                                              | no       |
| private_dns_name_options             | Private DNS name options                                                                                                                                                                                                         | `object`            | `null`                                                                                                                                                                                    | no       |
| private_ip                           | Private IP address                                                                                                                                                                                                               | `string`            | `null`                                                                                                                                                                                    | no       |
| private_key_algorithm                | Algorithm for private key                                                                                                                                                                                                        | `string`            | `RSA`                                                                                                                                                                                     | no       |
| private_key_rsa_bits                 | RSA key size in bits                                                                                                                                                                                                             | `number`            | `4096`                                                                                                                                                                                    | no       |
| public_key                           | Public key material for key pair                                                                                                                                                                                                 | `string`            | `null`                                                                                                                                                                                    | no       |
| region                               | AWS region                                                                                                                                                                                                                       | `string`            | `null`                                                                                                                                                                                    | no       |
| root_block_device                    | Root volume configuration                                                                                                                                                                                                        | `object`            | `null`                                                                                                                                                                                    | no       |
| secondary_private_ips                | Secondary private IP addresses                                                                                                                                                                                                   | `list(string)`      | `null`                                                                                                                                                                                    | no       |
| security_group_description           | Description for security group                                                                                                                                                                                                   | `string`            | `null`                                                                                                                                                                                    | no       |
| security_group_egress_rules          | Egress rules for Security Group                                                                                                                                                                                                  | `map(object)`       | `{ipv4_default={cidr_ipv4="0.0.0.0/0", description="Allow all IPv4 traffic", ip_protocol="-1"}, ipv6_default={cidr_ipv6="::/0", description="Allow all IPv6 traffic", ip_protocol="-1"}}` | no       |
| security_group_ingress_rules         | Ingress rules for Security Group                                                                                                                                                                                                 | `map(object)`       | `null`                                                                                                                                                                                    | no       |
| security_group_name                  | Name for security group                                                                                                                                                                                                          | `string`            | `null`                                                                                                                                                                                    | no       |
| security_group_tags                  | Tags for security group                                                                                                                                                                                                          | `map(string)`       | `{}`                                                                                                                                                                                      | no       |
| security_group_use_name_prefix       | Use name prefix for security group                                                                                                                                                                                               | `bool`              | `true`                                                                                                                                                                                    | no       |
| security_group_vpc_id                | VPC ID for security group                                                                                                                                                                                                        | `string`            | `null`                                                                                                                                                                                    | no       |
| source_dest_check                    | Enable source/destination check                                                                                                                                                                                                  | `bool`              | `null`                                                                                                                                                                                    | no       |
| spot_instance_interruption_behavior  | Spot instance interruption behavior                                                                                                                                                                                              | `string`            | `null`                                                                                                                                                                                    | no       |
| spot_launch_group                    | Spot launch group                                                                                                                                                                                                                | `string`            | `null`                                                                                                                                                                                    | no       |
| spot_price                           | Maximum price for spot instance                                                                                                                                                                                                  | `string`            | `null`                                                                                                                                                                                    | no       |
| spot_type                            | Type of spot request                                                                                                                                                                                                             | `string`            | `null`                                                                                                                                                                                    | no       |
| spot_valid_from                      | Spot request valid from                                                                                                                                                                                                          | `string`            | `null`                                                                                                                                                                                    | no       |
| spot_valid_until                     | Spot request valid until                                                                                                                                                                                                         | `string`            | `null`                                                                                                                                                                                    | no       |
| spot_wait_for_fulfillment            | Wait for spot fulfillment                                                                                                                                                                                                        | `bool`              | `null`                                                                                                                                                                                    | no       |
| subnet_id                            | ID of the subnet where to create the instance                                                                                                                                                                                    | `string`            | `null`                                                                                                                                                                                    | no       |
| subnet_name                          | Name of the subnet where to create the instance                                                                                                                                                                                  | `string`            | `null`                                                                                                                                                                                    | no       |
| tags                                 | Tags for the instance                                                                                                                                                                                                            | `map(string)`       | `{}`                                                                                                                                                                                      | no       |
| tenancy                              | Tenancy of the instance                                                                                                                                                                                                          | `string`            | `null`                                                                                                                                                                                    | no       |
| timeouts                             | Timeout configuration                                                                                                                                                                                                            | `object`            | `{}`                                                                                                                                                                                      | no       |
| user_data                            | Initialization script                                                                                                                                                                                                            | `string`            | `null`                                                                                                                                                                                    | no       |
| user_data_base64                     | Initialization script in base64                                                                                                                                                                                                  | `string`            | `null`                                                                                                                                                                                    | no       |
| user_data_replace_on_change          | Replace instance on user data change                                                                                                                                                                                             | `bool`              | `null`                                                                                                                                                                                    | no       |
| volume_tags                          | Tags for volumes                                                                                                                                                                                                                 | `map(string)`       | `{}`                                                                                                                                                                                      | no       |
| vpc_name                             | Name of the VPC                                                                                                                                                                                                                  | `string`            | `null`                                                                                                                                                                                    | no       |
| vpc_security_group_ids               | List of security group IDs. When `create_security_group = true` and not provided, defaults to `[]` (uses created security group). When `create_security_group = false` and not provided, defaults to default VPC security group. | `list(string)`      | `[]` (when creating security group) or default VPC security group (when not creating)                                                                                                     | no       |







## ⚠️ Important Notes
- **🚨 Instance Restart:** Some parameter changes may require instance restart. Plan maintenance windows accordingly.
- **⚠️ Public Access:** Control internet exposure with `associate_public_ip_address` and security group rules.
- **💰 Spot Instances:** Use spot instances for cost savings but ensure workloads are fault-tolerant.
- **🔐 Security:** Always use encrypted EBS volumes and restrictive security group rules.
- **📊 Monitoring:** Enable detailed monitoring for production workloads.



---

## 🤝 Contributing
We welcome contributions! Please see our contributing guidelines for more details.

## 🆘 Support
- 📧 **Email**: info@gocloud.la

## 🧑‍💻 About
We are focused on Cloud Engineering, DevOps, and Infrastructure as Code.
We specialize in helping companies design, implement, and operate secure and scalable cloud-native platforms.
- 🌎 [www.gocloud.la](https://www.gocloud.la)
- ☁️ AWS Advanced Partner (Terraform, DevOps, GenAI)
- 📫 Contact: info@gocloud.la

## 📄 License
This project is licensed under the Apache 2.0 License - see the [LICENSE](LICENSE) file for details. 