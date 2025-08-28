# DOCUMENTATION

## Introducción

El Wrapper de Terraform para AWS EC2 Instance simplifica la gestión y despliegue de instancias EC2 en Amazon Web Services.
Este wrapper funciona como una plantilla estandarizada que abstrae la complejidad técnica y permite crear múltiples instancias EC2 reutilizables que integran:

- **Instancias EC2 estándar** con configuración completa de CPU, memoria y almacenamiento
- **Instancias Spot** para cargas de trabajo tolerantes a interrupciones con precios reducidos
- **Elastic IP (EIP)** para direcciones IP públicas estáticas
- **Security Groups** con reglas de ingreso y egreso personalizables
- **IAM Instance Profiles** con roles y políticas de acceso granulares
- **EBS Volumes** adicionales con cifrado y configuración de rendimiento
- **Session Manager** para acceso seguro sin SSH tradicional
- **User Data** para inicialización automática de instancias
- **Hibernación y opciones de enclave** para casos de uso especializados
- **Integración con VPC** y subnets existentes

## Modo de Uso

```hcl
module "wrapper_ec2_instance" {
  source = "path/to/wrapper_ec2_instance"

  metadata = local.metadata
  project  = "mi-proyecto"

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
          cidr_blocks = ["0.0.0.0/0"]
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
}
```

## Parámetros de Configuración

| Parámetro | Tipo | Descripción | Categoría | Requerido | Valores/Ejemplo |
|-----------|------|-------------|-----------|-----------|------------------|
| `ami` | string | ID de la AMI a utilizar | Básico | No | `ami-0abcdef1234567890` |
| `ami_ssm_parameter` | string | Parámetro SSM para obtener AMI | Básico | No | `/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-x86_64` |
| `associate_public_ip_address` | bool | Asignar IP pública automáticamente | Red | No | `true/false` |
| `availability_zone` | string | Zona de disponibilidad | Red | No | `us-east-1a` |
| `capacity_reservation_specification` | object | Especificación de reserva de capacidad | Avanzado | No | Ver ejemplo |
| `cpu_credits` | string | Modo de créditos CPU para instancias T | Performance | No | `standard`, `unlimited` |
| `cpu_options` | object | Opciones de CPU | Performance | No | `{core_count = 2, threads_per_core = 1}` |
| `create` | bool | Crear la instancia | Control | No | `true/false` |
| `create_eip` | bool | Crear Elastic IP | Red | No | `true/false` |
| `create_iam_instance_profile` | bool | Crear IAM Instance Profile | IAM | No | `true/false` |
| `create_security_group` | bool | Crear Security Group | Seguridad | No | `true/false` |
| `create_spot_instance` | bool | Crear instancia Spot | Spot | No | `true/false` |
| `disable_api_stop` | bool | Deshabilitar parada por API | Protección | No | `true/false` |
| `disable_api_termination` | bool | Deshabilitar terminación por API | Protección | No | `true/false` |
| `ebs_optimized` | bool | Habilitar optimización EBS | Almacenamiento | No | `true/false` |
| `ebs_volumes` | map(object) | Volúmenes EBS adicionales | Almacenamiento | No | Ver ejemplo |
| `eip_domain` | string | Dominio del Elastic IP | Red | No | `vpc` |
| `eip_tags` | map(string) | Tags para el Elastic IP | Red | No | `{Name = "my-eip"}` |
| `enable_primary_ipv6` | bool | Habilitar IPv6 primaria | Red | No | `true/false` |
| `enable_volume_tags` | bool | Habilitar tags en volúmenes | Almacenamiento | No | `true/false` |
| `enclave_options_enabled` | bool | Habilitar AWS Nitro Enclaves | Performance | No | `true/false` |
| `ephemeral_block_device` | list(object) | Dispositivos de bloque efímeros | Almacenamiento | No | Ver ejemplo |
| `get_password_data` | bool | Obtener datos de contraseña (Windows) | Configuración | No | `true/false` |
| `hibernation` | bool | Habilitar hibernación | Performance | No | `true/false` |
| `host_id` | string | ID del host dedicado | Avanzado | No | `h-0123456789abcdef0` |
| `host_resource_group_arn` | string | ARN del grupo de recursos del host | Avanzado | No | `arn:aws:resource-groups:...` |
| `iam_instance_profile` | string | Instance Profile existente | IAM | No | `my-instance-profile` |
| `iam_role_description` | string | Descripción del rol IAM | IAM | No | `IAM role for EC2 instance` |
| `iam_role_name` | string | Nombre del rol IAM | IAM | No | `my-ec2-role` |
| `iam_role_path` | string | Ruta del rol IAM | IAM | No | `/ec2/` |
| `iam_role_permissions_boundary` | string | ARN del boundary de permisos | IAM | No | `arn:aws:iam::123456789012:policy/...` |
| `iam_role_policies` | map(string) | Políticas IAM a adjuntar | IAM | No | `{S3Access = "arn:aws:iam::aws:policy/AmazonS3FullAccess"}` |
| `iam_role_tags` | map(string) | Tags para el rol IAM | IAM | No | `{Purpose = "ec2-access"}` |
| `iam_role_use_name_prefix` | bool | Usar prefijo en nombre del rol | IAM | No | `true/false` |
| `ignore_ami_changes` | bool | Ignorar cambios en AMI | Configuración | No | `true/false` |
| `instance_initiated_shutdown_behavior` | string | Comportamiento al apagar | Protección | No | `stop`, `terminate` |
| `instance_market_options` | object | Opciones de mercado de instancia | Spot | No | Ver ejemplo |
| `instance_tags` | map(string) | Tags específicos de instancia | Metadatos | No | `{Name = "web-server"}` |
| `instance_type` | string | Tipo de instancia EC2 | Básico | No | `t3.micro`, `t3.small`, `m5.large` |
| `ipv6_address_count` | number | Número de direcciones IPv6 | Red | No | `1` |
| `ipv6_addresses` | list(string) | Direcciones IPv6 específicas | Red | No | `["2001:db8::1"]` |
| `key_name` | string | Nombre del Key Pair | Acceso | No | `my-keypair` |
| `launch_template` | object | Plantilla de lanzamiento | Avanzado | No | Ver ejemplo |
| `maintenance_options` | object | Opciones de mantenimiento | Avanzado | No | `{auto_recovery = "default"}` |
| `metadata_options` | object | Opciones de metadatos de instancia | Seguridad | No | Ver ejemplo |
| `monitoring` | bool | Habilitar monitoreo detallado | Monitoreo | No | `true/false` |
| `name` | string | Nombre de la instancia | Básico | No | `web-server-01` |
| `network_interface` | list(object) | Interfaces de red | Red | No | Ver ejemplo |
| `private_dns_name_options` | object | Opciones de DNS privado | Red | No | Ver ejemplo |
| `private_ip` | string | IP privada específica | Red | No | `10.0.1.100` |
| `putin_khuylo` | bool | Parámetro interno del módulo | Interno | No | `true` |
| `region` | string | Región AWS | Básico | No | `us-east-1` |
| `root_block_device` | object | Configuración del volumen raíz | Almacenamiento | No | Ver ejemplo |
| `secondary_private_ips` | list(string) | IPs privadas secundarias | Red | No | `["10.0.1.101", "10.0.1.102"]` |
| `security_group_description` | string | Descripción del Security Group | Seguridad | No | `Security group for web server` |
| `security_group_egress_rules` | map(object) | Reglas de egreso del Security Group | Seguridad | No | Ver ejemplo |
| `security_group_ingress_rules` | map(object) | Reglas de ingreso del Security Group | Seguridad | No | Ver ejemplo |
| `security_group_name` | string | Nombre del Security Group | Seguridad | No | `my-sg` |
| `security_group_tags` | map(string) | Tags para el Security Group | Seguridad | No | `{Purpose = "web-access"}` |
| `security_group_use_name_prefix` | bool | Usar prefijo en nombre del SG | Seguridad | No | `true/false` |
| `security_group_vpc_id` | string | ID de la VPC para el Security Group | Seguridad | No | `vpc-12345678` |
| `source_dest_check` | bool | Verificación origen/destino | Red | No | `true/false` |
| `spot_instance_interruption_behavior` | string | Comportamiento al interrumpir Spot | Spot | No | `hibernate`, `stop`, `terminate` |
| `spot_launch_group` | string | Grupo de lanzamiento Spot | Spot | No | `my-spot-group` |
| `spot_price` | string | Precio máximo para instancia Spot | Spot | No | `0.05` |
| `spot_type` | string | Tipo de solicitud Spot | Spot | No | `one-time`, `persistent` |
| `spot_valid_from` | string | Fecha de inicio válida para Spot | Spot | No | `2023-01-01T00:00:00Z` |
| `spot_valid_until` | string | Fecha de fin válida para Spot | Spot | No | `2023-12-31T23:59:59Z` |
| `spot_wait_for_fulfillment` | bool | Esperar cumplimiento de Spot | Spot | No | `true/false` |
| `subnet_id` | string | ID de la subnet donde crear la instancia | Red | No | `subnet-12345678` |
| `tags` | map(string) | Tags para la instancia | Metadatos | No | `{Environment = "prod"}` |
| `tenancy` | string | Tenencia de la instancia | Avanzado | No | `default`, `dedicated`, `host` |
| `timeouts` | object | Timeouts para operaciones | Configuración | No | `{create = "10m", update = "10m", delete = "20m"}` |
| `user_data` | string | Script de inicialización | Configuración | No | `#!/bin/bash\necho "Hello World"` |
| `user_data_base64` | string | Script de inicialización en base64 | Configuración | No | `IyEvYmluL2Jhc2g=` |
| `user_data_replace_on_change` | bool | Reemplazar instancia al cambiar user_data | Configuración | No | `true/false` |
| `volume_tags` | map(string) | Tags para volúmenes | Metadatos | No | `{Backup = "daily"}` |
| `vpc_security_group_ids` | list(string) | IDs de Security Groups existentes | Seguridad | No | `["sg-12345678"]` |

## Ejemplos de Configuración

### Instancia Web Básica

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
        cidr_blocks = ["0.0.0.0/0"]
        from_port   = 80
        to_port     = 80
        protocol    = "tcp"
      }
    }
    
    user_data_base64 = base64encode(<<-EOF
      #!/bin/bash
      yum update -y
      yum install -y httpd
      systemctl start httpd
      systemctl enable httpd
    EOF
    )
  }
}
```

### Instancia con Session Manager

```hcl
ec2_instance_parameters = {
  "session-manager" = {
    instance_type = "t3.micro"
    subnet_id     = data.aws_subnets.private.ids[0]
    
    create_iam_instance_profile = true
    iam_role_policies = {
      SSMCore = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
    }
  }
}
```

### Instancia Spot

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

### Instancia con Almacenamiento Personalizado

```hcl
ec2_instance_parameters = {
  "storage-optimized" = {
    instance_type = "m5.xlarge"
    subnet_id     = data.aws_subnets.private.ids[0]
    
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
        tags = {
          Purpose = "application-data"
        }
      }
      "/dev/sdg" = {
        size      = 100
        type      = "io2"
        encrypted = true
        iops      = 1000
        tags = {
          Purpose = "database"
        }
      }
    }
  }
}
```

### Permisos IAM Requeridos

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ec2:*",
        "iam:CreateRole",
        "iam:CreateInstanceProfile",
        "iam:AttachRolePolicy",
        "iam:PassRole",
        "iam:GetRole",
        "iam:GetInstanceProfile",
        "iam:ListAttachedRolePolicies",
        "iam:TagRole",
        "iam:TagInstanceProfile"
      ],
      "Resource": "*"
    }
  ]
}
```

## Mejores Prácticas

### Seguridad

1. **Siempre cifrar volúmenes EBS**:
   ```hcl
   root_block_device = {
     encrypted = true
   }
   ```

2. **Usar Security Groups restrictivos**:
   ```hcl
   security_group_ingress_rules = {
     "ssh" = {
       cidr_blocks = ["10.0.0.0/8"]  # Solo red interna
       from_port   = 22
       to_port     = 22
       protocol    = "tcp"
     }
   }
   ```

3. **Configurar metadatos seguros**:
   ```hcl
   metadata_options = {
     http_endpoint = "enabled"
     http_tokens   = "required"
     http_put_response_hop_limit = 1
   }
   ```

### Performance

1. **Usar instancias optimizadas para EBS cuando sea necesario**:
   ```hcl
   ebs_optimized = true
   ```

2. **Configurar créditos CPU ilimitados para cargas variables**:
   ```hcl
   cpu_credits = "unlimited"
   ```

### Costos

1. **Usar instancias Spot para cargas tolerantes a interrupciones**:
   ```hcl
   create_spot_instance = true
   spot_price          = "0.05"
   ```

2. **Configurar hibernación para instancias de desarrollo**:
   ```hcl
   hibernation = true
   ```

### Monitoreo

1. **Habilitar monitoreo detallado**:
   ```hcl
   monitoring = true
   ```

2. **Usar tags consistentes**:
   ```hcl
   tags = {
     Environment = "production"
     Application = "web-server"
     Owner       = "team-backend"
     CostCenter  = "engineering"
   }
   ```

## Troubleshooting

### Problemas Comunes

1. **Error de permisos IAM**: Verificar que el usuario/rol tenga permisos para crear instancias EC2 y recursos IAM.

2. **Subnet no encontrada**: Asegurar que la subnet especificada existe y está en la VPC correcta.

3. **AMI no disponible**: Verificar que la AMI especificada existe en la región actual.

4. **Límites de instancias**: Verificar los límites de servicio de EC2 en la cuenta AWS.
