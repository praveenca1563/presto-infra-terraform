variable "storage_account_name" {
  description = "Globally unique storage account name (lowercase, no special chars)"
  type        = string
}

variable "resource_group_name" {
  type = string
}

variable "location" {
  type = string
}

variable "account_tier" {
  description = "Standard or Premium"
  type        = string
  default     = "Standard"
}

variable "replication_type" {
  description = "LRS, GRS, ZRS, RAGRS, etc."
  type        = string
  default     = "LRS"
}

variable "public_network_access_enabled" {
  description = "Enable public network access to the storage account"
  type        = bool
  default     = true
}

variable "network_default_action" {
  description = "Allow or Deny for the storage account network rule default action"
  type        = string
  default     = "Deny"
}

variable "allowed_subnet_ids" {
  description = "Subnet IDs allowed through the storage firewall (private networking)"
  type        = list(string)
  default     = []
}

variable "allowed_ip_ranges" {
  description = "Public IP ranges allowed through the storage firewall, if any"
  type        = list(string)
  default     = []
}

variable "blob_soft_delete_days" {
  type    = number
  default = 7
}

variable "containers" {
  description = "List of container names to create (e.g. raw, bronze, silver, gold)"
  type        = list(string)
  default     = []
}

variable "folders" {
  description = "List of logical folders to create inside containers, e.g. [{container = \"gold\", path = \"data_management\"}]"
  type = list(object({
    container = string
    path      = string
  }))
  default = []
}

variable "tags" {
  type    = map(string)
  default = {}
}
<<<<<<< HEAD
variable "rbac_dependency" {
  description = "Dependency used to ensure storage data-plane RBAC is available before creating blobs."
  type        = any
  default     = null
}
=======
>>>>>>> origin/Dev
