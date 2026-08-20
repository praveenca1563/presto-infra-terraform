############################
# Authentication
############################

variable "azure_subscription_id" {
  description = "Azure Subscription ID."
  type        = string
  sensitive   = true

  validation {
    condition     = length(var.azure_subscription_id) > 0
    error_message = "Azure Subscription ID cannot be empty."
  }
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

  validation {
    condition     = length(var.github_token) > 0
    error_message = "GitHub token cannot be empty."
  }
}


############################
# General
############################

variable "environment" {
  description = "Deployment environment."
  type        = string

  validation {
    condition = contains(
      ["dev", "qa", "uat", "nonprod", "prod"],
      lower(var.environment)
    )

    error_message = "Environment must be one of: dev, qa, uat, nonprod or prod."
  }
}

variable "location" {
  description = "Azure region."
  type        = string

  validation {
    condition = contains([
      "Canada Central",
    ], var.location)

    error_message = "Unsupported Azure region."
  }
}

variable "common_tags" {
  type    = map(string)
  default = {}
}


############################
# Naming Standard
############################
# Drives the auto-generated names in local.tf. Any *_name variable above can
# still be set explicitly in tfvars to override the generated value.

variable "naming_project" {
  description = "Short project token used in generated resource names."
  type        = string
  default     = "presto"

  validation {
    condition     = can(regex("^[a-z0-9]+$", var.naming_project))
    error_message = "naming_project must be lowercase alphanumeric."
  }
}

variable "naming_instance" {
  description = "Zero-padded instance/sequence token used in generated resource names (e.g. \"001\")."
  type        = string
  default     = "001"

  validation {
    condition     = can(regex("^[0-9]{3}$", var.naming_instance))
    error_message = "naming_instance must be a 3-digit zero-padded number, e.g. \"001\"."
  }
}

variable "naming_region_abbreviations" {
  description = "Map of Azure region full names to the short token used in generated resource names."
  type        = map(string)

  default = {
    "Canada Central" = "cc"
  }
}


############################
# Existing Resource Groups
############################

variable "existing_infra_resource_group_name" {
  description = "Existing Infrastructure Resource Group"
  type        = string
}

variable "existing_data_resource_group_name" {
  description = "Existing Data Resource Group"
  type        = string
}

variable "existing_network_resource_group_name" {
  description = "Existing Network Resource Group containing Vnet,subnets,nsgs,routetables"
  type        = string
}


############################
# Networking
############################

variable "vnet_name" {
  type = string
}

variable "subnets" {
  description = "Existing Azure subnets to be used by the platform."

  type = map(object({
    name             = string
    nsg_name         = string
    route_table_name = optional(string)
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
  description = "Azure Storage Account name. Leave null to auto-generate from the naming standard in local.tf."
  type        = string
  default     = null

  validation {
    condition = (
      var.storage_account_name == null || (
        length(var.storage_account_name) >= 3 &&
        length(var.storage_account_name) <= 24 &&
        can(regex("^[a-z0-9]+$", var.storage_account_name))
      )
    )

    error_message = "Storage account names must be 3-24 lowercase alphanumeric characters."
  }
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

  default = [
    {
      container = "gold"
      path      = "data_management"
    }
  ]
}

variable "storage_public_network_access_enabled" {
  type    = bool
  default = true
}


############################
# Data Factory
############################

variable "data_factory_name" {
  description = "Azure Data Factory name. Leave null to auto-generate from the naming standard in local.tf."
  type        = string
  default     = null
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
  description = "Azure Databricks workspace name. Leave null to auto-generate from the naming standard in local.tf."
  type        = string
  default     = null
}

variable "databricks_managed_rg_name" {
  description = "Databricks-managed resource group name. Leave null to auto-generate from the naming standard in local.tf."
  type        = string
  default     = null
}

variable "databricks_sku" {
  type    = string
  default = "premium"

  validation {
    condition = contains(
      ["standard", "premium"],
      lower(var.databricks_sku)
    )

    error_message = "Databricks SKU must be Standard or Premium."
  }
}

variable "databricks_metastore_admin_object_ids" {
  type    = list(string)
  default = []
}


############################
# Key Vault
############################

variable "key_vault_name" {
  description = "Azure Key Vault name. Leave null to auto-generate from the naming standard in local.tf."
  type        = string
  default     = null

  validation {
    condition = (
      var.key_vault_name == null || (
        length(var.key_vault_name) >= 3 &&
        length(var.key_vault_name) <= 24 &&
        can(regex("^[a-z0-9-]+$", var.key_vault_name))
      )
    )

    error_message = "Invalid Key Vault name."
  }
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
# GitHub Repository
############################

variable "repository_name" {
  type = string

  validation {
    condition     = length(var.repository_name) > 0
    error_message = "Repository name cannot be empty."
  }
}

variable "repository_description" {
  type    = string
  default = "Terraform infrastructure-as-code for the PRESTO Data Platform"
}

variable "repository_visibility" {
  type    = string
  default = "private"

  validation {
    condition = contains(
      ["private", "public", "internal"],
      lower(var.repository_visibility)
    )

    error_message = "Repository visibility must be private, public or internal."
  }
}

variable "required_approving_review_count" {
  type    = number
  default = 1
}

variable "enable_branch_protection" {
  type    = bool
  default = false
}


############################
# GitHub Self-hosted Runners
############################

# Self-hosted runners are no longer managed by this Terraform project.
# GitHub-hosted runners are used by GitHub Actions workflows.


############################
# End
############################