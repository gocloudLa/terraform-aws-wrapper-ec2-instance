/*----------------------------------------------------------------------*/
/* Common |                                                             */
/*----------------------------------------------------------------------*/

# variable "metadata" {
#   type = any
# }

/*----------------------------------------------------------------------*/
/* EC2 Instance | Variable Definition                                   */
/*----------------------------------------------------------------------*/

variable "ec2_instance_defaults" {
  description = "Map of default values which will be used for each ec2 database."
  type        = any
  default     = {}
}

variable "ec2_instance_parameters" {
  description = "Maps of ec2 databases to create a wrapper from. Values are passed through to the module."
  type        = any
  default     = {}
}