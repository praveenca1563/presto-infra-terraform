variable "data_factory_name" {
  type = string
}

variable "resource_group_name" {
  type = string
}

variable "location" {
  type = string
}

variable "public_network_enabled" {
  description = "Set false once the private endpoint is active, per environment request doc"
  type        = bool
  default     = true
}

variable "managed_virtual_network_enabled" {
  description = "Enable Managed Virtual Network"
  type        = bool
  default     = true
}

variable "storage_account_id" {
  description = "Resource ID of the ADLS Gen2 storage account to grant this ADF's managed identity access to"
  type        = string
  default     = null
}

variable "contributor_group_object_ids" {
  description = "AAD group object IDs to grant Data Factory Contributor (e.g. AZ-DEV-PRESTO-CON)"
  type        = list(string)
  default     = []
}

variable "reader_group_object_ids" {
  description = "AAD group object IDs to grant Reader"
  type        = list(string)
  default     = []
}

variable "tags" {
  type    = map(string)
  default = {}
}
