variable "key_vault_name" {
  type = string
}

variable "resource_group_name" {
  type = string
}

variable "location" {
  type = string
}

variable "tenant_id" {
  type = string
}

variable "sku_name" {
  type    = string
  default = "standard"
}

variable "purge_protection_enabled" {
  type    = bool
  default = true
}

variable "soft_delete_retention_days" {
  type    = number
  default = 90
}

variable "public_network_access_enabled" {
  type    = bool
  default = false
}

variable "network_default_action" {
  type    = string
  default = "Deny"
}

variable "allowed_subnet_ids" {
  type    = list(string)
  default = []
}

variable "admin_object_ids" {
  description = "Object IDs (users/groups/SPNs) granted Key Vault Administrator"
  type        = list(string)
  default     = []
}

variable "secrets_reader_object_ids" {
  description = "Object IDs granted Key Vault Secrets User (read-only)"
  type        = list(string)
  default     = []
}

variable "secrets" {
  description = "Map of secret name -> value to store. Pass sensitive values via TF_VAR_ environment variables or a CI secret store, never in a committed .tfvars file."
  type        = map(string)
  default     = {}
  sensitive   = true
}

variable "tags" {
  type    = map(string)
  default = {}
}
