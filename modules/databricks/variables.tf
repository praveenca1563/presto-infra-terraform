variable "workspace_name" {
  type = string
}

variable "resource_group_name" {
  type = string
}

variable "location" {
  type = string
}

variable "sku" {
  description = "standard, premium, or trial"
  type        = string
  default     = "premium" # premium required for Unity Catalog / SCIM / Databricks SQL
}

variable "managed_resource_group_name" {
  description = "Name for the Databricks-managed resource group"
  type        = string
}

variable "public_network_access_enabled" {
  type    = bool
  default = false
}

variable "enable_vnet_injection" {
  description = "Deploy Databricks into the existing core VNet (VNet injection) rather than a managed VNet"
  type        = bool
  default     = true
}

variable "vnet_id" {
  type    = string
  default = null
}

variable "public_subnet_name" {
  type    = string
  default = null
}

variable "private_subnet_name" {
  type    = string
  default = null
}

variable "public_subnet_nsg_association_id" {
  type    = string
  default = null
}

variable "private_subnet_nsg_association_id" {
  type    = string
  default = null
}

variable "metastore_admin_object_ids" {
  description = "Object IDs (e.g. AZ-METASTORE-ADM-GRP) responsible for schema access control"
  type        = list(string)
  default     = []
}

variable "tags" {
  type    = map(string)
  default = {}
}
variable "no_public_ip" {
  description = "Enable secure cluster connectivity (No Public IP)"
  type        = bool
  default     = true
}