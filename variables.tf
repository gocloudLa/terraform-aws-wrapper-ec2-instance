/*----------------------------------------------------------------------*/
/* Common |                                                             */
/*----------------------------------------------------------------------*/

variable "metadata" {
  type = any
}

variable "project" {
  type = string
}

/*----------------------------------------------------------------------*/
/* ALB | Variable Definition                                            */
/*----------------------------------------------------------------------*/

variable "ec2_instance_parameters" {
  type        = any
  description = ""
  default     = {}
}

variable "ec2_instance_defaults" {
  description = "Map of default values which will be used for each item."
  type        = any
  default     = {}
}