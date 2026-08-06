############################
# Authentication (all sensitive — supply via TF_VAR_ env vars or CI secrets,
# never in a committed .tfvars file)
############################

variable "azure_subscription_id" {
  type      = string
  sensitive = true
}

variable "azure_tenant_id" {
  type      = string
  sensitive = true
}

variable "azure_client_id" {
  type      = string
  sensitive = true
}

variable "azure_client_secret" {
  type      = string
  sensitive = true
}

variable "github_owner" {
  description = "GitHub organization or user that will own the repository"
  type        = string
}

variable "github_token" {
  description = "GitHub PAT or GitHub App token with repo admin scope, used by the github provider to create the repo/secrets/branch protection"
  type        = string
  sensitive   = true
}

############################
# General
############################

variable "environment" {
  description = "Environment name, e.g. dev / nonprod / prod"
  type        = string
}

variable "location" {
  description = "Azure region, e.g. canadacentral"
  type        = string
}

variable "common_tags" {
  type    = map(string)
  default = {}
}

############################
# Resource groups
############################

variable "resource_groups" {
  type = map(object({
    name     = string
    location = string
    tags     = optional(map(string), {})
  }))
}

variable "infra_rg_key" {
  description = "Key (from resource_groups map) of the RG that holds networking/keyvault/runner infra"
  type        = string
}

variable "data_rg_key" {
  description = "Key (from resource_groups map) of the RG that holds ADF/storage/Databricks"
  type        = string
}

############################
# Networking
############################

variable "vnet_name" {
  type = string
}

variable "vnet_address_space" {
  type = list(string)
}

variable "create_route_table" {
  type    = bool
  default = false
}

variable "subnets" {
  type = map(object({
    name             = string
    address_prefixes = list(string)
    nsg_name         = string
    route_table_name = optional(string)
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

variable "databricks_public_subnet_key" {
  description = "Key into var.subnets for the Databricks public (host) subnet"
  type        = string
}

variable "databricks_private_subnet_key" {
  description = "Key into var.subnets for the Databricks private (container) subnet"
  type        = string
}

variable "data_subnet_key" {
  description = "Key into var.subnets used for private endpoints / data services"
  type        = string
}

############################
# Storage (ADLS Gen2)
############################

variable "storage_account_name" {
  type = string
}

variable "storage_containers" {
  type    = list(string)
  default = ["raw", "bronze", "silver", "gold"]
}

variable "storage_folders" {
  type = list(object({
    container = string
    path      = string
  }))
  default = [{ container = "gold", path = "data_management" }]
}

variable "storage_public_network_access_enabled" {
  type    = bool
  default = false
}

############################
# Data Factory
############################

variable "data_factory_name" {
  type = string
}

variable "adf_public_network_enabled" {
  type    = bool
  default = true
}

variable "adf_contributor_group_object_ids" {
  type    = list(string)
  default = []
}

variable "adf_reader_group_object_ids" {
  type    = list(string)
  default = []
}

############################
# Databricks
############################

variable "databricks_workspace_name" {
  type = string
}

variable "databricks_managed_rg_name" {
  type = string
}

variable "databricks_sku" {
  type    = string
  default = "premium"
}

variable "databricks_metastore_admin_object_ids" {
  type    = list(string)
  default = []
}

############################
# Key Vault
############################

variable "key_vault_name" {
  type = string
}

variable "key_vault_admin_object_ids" {
  type    = list(string)
  default = []
}

variable "key_vault_secrets_reader_object_ids" {
  type    = list(string)
  default = []
}

############################
# GitHub repository
############################

variable "repository_name" {
  type = string
}

variable "repository_description" {
  type    = string
  default = "Terraform infrastructure-as-code for the PRESTO Data Platform"
}

variable "repository_visibility" {
  type    = string
  default = "private"
}

variable "required_approving_review_count" {
  type    = number
  default = 1
}

############################
# GitHub self-hosted runners
############################

variable "enable_github_runners" {
  type    = bool
  default = true
}

variable "runner_vmss_name" {
  type    = string
  default = ""
}

variable "runner_vm_size" {
  type    = string
  default = "Standard_D2s_v5"
}

variable "runner_instance_count" {
  type    = number
  default = 2
}

variable "runner_ssh_public_key" {
  type = string
}

variable "runner_registration_token" {
  description = "Short-lived GitHub Actions runner registration token (see README)"
  type        = string
  sensitive   = true
  default     = ""
}

variable "runner_autoscale_min" {
  type    = number
  default = 1
}

variable "runner_autoscale_max" {
  type    = number
  default = 5
}
