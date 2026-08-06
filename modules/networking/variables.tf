############################################################
# Existing Azure Virtual Network
############################################################

variable "vnet_name" {
  description = "Name of the existing Virtual Network."
  type        = string
}

variable "resource_group_name" {
  description = "Resource Group containing the existing Virtual Network."
  type        = string
}

############################################################
# Existing Subnets
############################################################

variable "subnets" {
  description = "Existing subnets to look up."

  type = map(object({
    name             = string
    nsg_name         = string
    route_table_name = optional(string)
  }))
}

############################################################
# Tags
############################################################

variable "tags" {
  description = "Tags (retained for module compatibility)."
  type        = map(string)
  default     = {}
}