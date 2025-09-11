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
ec2_instance_parameters = {
  "web-server" = {
    ami                    = data.aws_ami.amazon_linux.id
    instance_type          = "t3.medium"
    availability_zone      = data.aws_availability_zones.available.names[0]
    subnet_id              = data.aws_subnets.private.ids[0]
    
    # Elastic IP
    create_eip             = true
    
    # Security Group
    create_security_group = true
    security_group_ingress_rules = {
      "http" = {
        cidr_blocks = ["10.0.0.0/8"]
        description = "HTTP access"
        from_port   = 80
        protocol    = "tcp"
        to_port     = 80
      }
      "ssh" = {
        cidr_blocks = ["10.0.0.0/8"]
        description = "SSH access"
        from_port   = 22
        protocol    = "tcp"
        to_port     = 22
      }
    }
    
    # IAM Role
    create_iam_instance_profile = true
    iam_role_description        = "IAM role for web server"
    iam_role_policies = {
      S3ReadOnly = "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"
    }
    
    # Storage
    root_block_device = {
      encrypted  = true
      type       = "gp3"
      size       = 20
    }
    
    ebs_volumes = {
      "/dev/sdf" = {
        size       = 100
        encrypted  = true
        type       = "gp3"
      }
    }
    
    # User Data
    user_data_base64 = base64encode(<<-EOF
      #!/bin/bash
      yum update -y
      yum install -y httpd
      systemctl start httpd
      systemctl enable httpd
    EOF
    )
    
    tags = {
      Environment = "production"
      Application = "web-server"
    }
  }
}
```


## 🔧 Additional Features Usage

### Standard EC2 Instances
Deploy standard EC2 instances with complete configuration including CPU, memory, and storage options.
Supports various instance types from t3.micro to high-performance instances.


<details><summary>Basic Web Server</summary>

```hcl
ec2_instance_parameters = {
  "web-basic" = {
    ami           = data.aws_ami.amazon_linux.id
    instance_type = "t3.small"
    subnet_id     = data.aws_subnets.public.ids[0]
    
    create_eip = true
    
    create_security_group = true
    security_group_ingress_rules = {
      "http" = {
        cidr_blocks = ["10.0.0.0/8"]
        from_port   = 80
        to_port     = 80
        protocol    = "tcp"
      }
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
  "spot-instance" = {
    create_spot_instance = true
    spot_price          = "0.05"
    spot_type           = "persistent"
    
    instance_type = "m5.large"
    subnet_id     = data.aws_subnets.private.ids[0]
  }
}
```


</details>


### Security Groups & IAM
Create and manage Security Groups with customizable rules and IAM Instance Profiles with granular access policies.
Supports both custom security groups and existing ones, with comprehensive IAM role management.


<details><summary>Security Configuration</summary>

```hcl
ec2_instance_parameters = {
  "secure-instance" = {
    create_iam_instance_profile = true
    iam_role_policies = {
      SSMCore = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
    }
    
    create_security_group = true
    security_group_ingress_rules = {
      "ssh" = {
        cidr_blocks = ["10.0.0.0/8"]
        from_port   = 22
        to_port     = 22
        protocol    = "tcp"
      }
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
  "storage-optimized" = {
    root_block_device = {
      encrypted  = true
      type       = "gp3"
      size       = 50
      throughput = 250
      iops       = 3000
    }
    
    ebs_volumes = {
      "/dev/sdf" = {
        size       = 500
        type       = "gp3"
        encrypted  = true
        throughput = 500
        iops       = 4000
      }
    }
  }
}
```


</details>


### SSH Key Pairs
Automatically create SSH key pairs for EC2 instances with secure private key storage in AWS Systems Manager Parameter Store.
Supports RSA and ED25519 algorithms with configurable key sizes and automatic key rotation.


<details><summary>SSH Key Configuration</summary>

```hcl
ec2_instance_parameters = {
  "web-server" = {
    create_ssh_key         = true
    create_private_key     = true
    private_key_algorithm  = "RSA"
    private_key_rsa_bits   = 4096
  }
}
```


</details>


### Custom IAM Policies
Create and attach custom IAM policies to EC2 instances with automatic role integration.
Define custom permissions and policies that are automatically attached to the instance IAM role.


<details><summary>Custom Policy Configuration</summary>

```hcl
ec2_instance_parameters = {
  "app-server" = {
    create_custom_policy = true
    custom_policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Effect = "Allow"
          Action = ["s3:GetObject", "s3:PutObject"]
          Resource = "arn:aws:s3:::my-bucket/*"
        }
      ]
    })
  }
}
```


</details>




## 📑 Inputs
| Name                         | Description                                   | Type          | Default      | Required |
| ---------------------------- | --------------------------------------------- | ------------- | ------------ | -------- |
| ami                          | ID of the AMI to use                          | `string`      | `null`       | no       |
| ami_ssm_parameter            | SSM parameter to get AMI                      | `string`      | `null`       | no       |
| associate_public_ip_address  | Assign public IP automatically                | `bool`        | `null`       | no       |
| availability_zone            | Availability zone                             | `string`      | `null`       | no       |
| create_custom_policy         | Create custom IAM policy                      | `bool`        | `false`      | no       |
| create_eip                   | Create Elastic IP                             | `bool`        | `false`      | no       |
| create_iam_instance_profile  | Create IAM Instance Profile                   | `bool`        | `false`      | no       |
| create_private_key           | Create private key and store it in SSM        | `bool`        | `false`      | no       |
| create_security_group        | Create Security Group                         | `bool`        | `false`      | no       |
| create_spot_instance         | Create spot instance                          | `bool`        | `false`      | no       |
| create_ssh_key               | Create SSH key pair                           | `bool`        | `false`      | no       |
| custom_policy                | Custom IAM policy JSON                        | `string`      | `null`       | no       |
| disable_api_termination      | Disable API termination                       | `bool`        | `null`       | no       |
| ebs_optimized                | Enable EBS optimization                       | `bool`        | `null`       | no       |
| ebs_volumes                  | Additional EBS volumes                        | `map(object)` | `{}`         | no       |
| iam_role_policies            | IAM policies to attach                        | `map(string)` | `{}`         | no       |
| instance_type                | Type of EC2 instance                          | `string`      | `"t3.micro"` | no       |
| key_name                     | Name of the Key Pair                          | `string`      | `null`       | no       |
| key_name_prefix              | Prefix for generated key name                 | `string`      | `null`       | no       |
| monitoring                   | Enable detailed monitoring                    | `bool`        | `false`      | no       |
| private_key_algorithm        | Algorithm for private key                     | `string`      | `"RSA"`      | no       |
| private_key_rsa_bits         | RSA key size in bits                          | `number`      | `4096`       | no       |
| public_key                   | Public key material for key pair              | `string`      | `null`       | no       |
| root_block_device            | Root volume configuration                     | `object`      | `{}`         | no       |
| security_group_egress_rules  | Egress rules for Security Group               | `map(object)` | `{}`         | no       |
| security_group_ingress_rules | Ingress rules for Security Group              | `map(object)` | `{}`         | no       |
| spot_price                   | Maximum price for spot instance               | `string`      | `null`       | no       |
| spot_type                    | Type of spot request                          | `string`      | `"one-time"` | no       |
| subnet_id                    | ID of the subnet where to create the instance | `string`      | `null`       | no       |
| user_data                    | Initialization script                         | `string`      | `null`       | no       |
| disable_api_stop             | Disable stop via API                          | `bool`        | `false`      | no       |
| hibernation                  | Enable hibernation                            | `bool`        | `false`      | no       |
| cpu_credits                  | CPU credits mode for T instances              | `string`      | `null`       | no       |
| metadata_options             | Instance metadata options                     | `object`      | `{}`         | no       |
| tags                         | Tags for the instance                         | `map(string)` | `{}`         | no       |







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