variable "vnet_name" {
  description = "Name of the virtual network"
  type        = string
}

variable "vnet_address_space" {
  description = "Address space(s) for the virtual network"
  type        = list(string)
}

variable "location" {
  description = "Azure region"
  type        = string
}

variable "resource_group_name" {
  description = "Resource group in which to create networking resources"
  type        = string
}

variable "create_route_table" {
  description = "If true, create the route table(s) referenced by subnets. If false, look them up as pre-existing (owned by network team)."
  type        = bool
  default     = false
}

variable "subnets" {
  description = "Map of subnets to create, keyed by a logical name."
  type = map(object({
    name              = string
    address_prefixes  = list(string)
    nsg_name          = string
    route_table_name  = optional(string)
    nsg_rules = optional(list(object({
      name                        = string
      priority                    = number
      direction                   = string
      access                      = string
      protocol                    = string
      source_port_range           = optional(string)
      destination_port_range      = optional(string)
      source_address_prefix       = optional(string)
      destination_address_prefix  = optional(string)
    })), [])
    delegation = optional(object({
      name         = string
      service_name = string
      actions      = list(string)
    }))
  }))
}

variable "tags" {
  description = "Tags applied to all networking resources"
  type        = map(string)
  default     = {}
}
