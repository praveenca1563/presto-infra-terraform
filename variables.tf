############################
<<<<<<< HEAD
# Authentication
=======
# Authentication (all sensitive — supply via TF_VAR_ env vars or CI secrets,
# never in a committed .tfvars file)
>>>>>>> origin/Dev
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
<<<<<<< HEAD

=======
>>>>>>> origin/Dev
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

<<<<<<< HEAD

=======
>>>>>>> origin/Dev
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
<<<<<<< HEAD
  type        = string

  validation {
    condition = contains([
      "Canada Central",
    ], var.location)

    error_message = "Unsupported Azure region."
=======

  type = string

  validation {

    condition = contains([
      "East US",
      "East US 2",
      "Central US",
      "West US",
      "West US 2",
      "Canada Central",
      "Canada East",
      "North Europe",
      "West Europe",
      "Southeast Asia",
      "Australia East"
    ], var.location)

    error_message = "Unsupported Azure region."

>>>>>>> origin/Dev
  }
}

variable "common_tags" {
  type    = map(string)
  default = {}
}

<<<<<<< HEAD

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


=======
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

variable "data_rg_key" {
  description = "Key (from resource_groups map) of the RG that holds ADF/storage/Databricks"
  type        = string
}

>>>>>>> origin/Dev
############################
# Networking
############################

variable "vnet_name" {
  type = string
}

<<<<<<< HEAD
=======

>>>>>>> origin/Dev
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

<<<<<<< HEAD

=======
>>>>>>> origin/Dev
############################
# Storage (ADLS Gen2)
############################

variable "storage_account_name" {
<<<<<<< HEAD
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
=======

  description = "Azure Storage Account name."

  type = string

  validation {

    condition = (
      length(var.storage_account_name) >= 3 &&
      length(var.storage_account_name) <= 24 &&
      can(regex("^[a-z0-9]+$", var.storage_account_name))
    )

    error_message = "Storage account names must be 3-24 lowercase alphanumeric characters."

  }

>>>>>>> origin/Dev
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
<<<<<<< HEAD

  default = [
    {
      container = "gold"
      path      = "data_management"
    }
  ]
=======
  default = [{ container = "gold", path = "data_management" }]
>>>>>>> origin/Dev
}

variable "storage_public_network_access_enabled" {
  type    = bool
  default = true
}

<<<<<<< HEAD

=======
>>>>>>> origin/Dev
############################
# Data Factory
############################

variable "data_factory_name" {
<<<<<<< HEAD
  description = "Azure Data Factory name. Leave null to auto-generate from the naming standard in local.tf."
  type        = string
  default     = null
=======
  type = string
>>>>>>> origin/Dev
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

<<<<<<< HEAD

=======
>>>>>>> origin/Dev
############################
# Databricks
############################

variable "databricks_workspace_name" {
<<<<<<< HEAD
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
=======
  type = string
}

variable "databricks_managed_rg_name" {
  type = string
}

variable "databricks_sku" {

>>>>>>> origin/Dev
  type    = string
  default = "premium"

  validation {
<<<<<<< HEAD
=======

>>>>>>> origin/Dev
    condition = contains(
      ["standard", "premium"],
      lower(var.databricks_sku)
    )

    error_message = "Databricks SKU must be Standard or Premium."
<<<<<<< HEAD
  }
=======

  }

>>>>>>> origin/Dev
}

variable "databricks_metastore_admin_object_ids" {
  type    = list(string)
  default = []
}

<<<<<<< HEAD

=======
>>>>>>> origin/Dev
############################
# Key Vault
############################

variable "key_vault_name" {
<<<<<<< HEAD
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
=======
  type = string

  validation {

    condition = (
      length(var.key_vault_name) >= 3 &&
      length(var.key_vault_name) <= 24 &&
      can(regex("^[a-z0-9-]+$", var.key_vault_name))
    )

    error_message = "Invalid Key Vault name."

>>>>>>> origin/Dev
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

<<<<<<< HEAD

############################
# GitHub Repository
=======
############################
# GitHub repository
>>>>>>> origin/Dev
############################

variable "repository_name" {
  type = string

  validation {
<<<<<<< HEAD
    condition     = length(var.repository_name) > 0
    error_message = "Repository name cannot be empty."
=======

    condition = length(var.repository_name) > 0

    error_message = "Repository name cannot be empty."

>>>>>>> origin/Dev
  }
}

variable "repository_description" {
  type    = string
  default = "Terraform infrastructure-as-code for the PRESTO Data Platform"
}

variable "repository_visibility" {
<<<<<<< HEAD
=======

>>>>>>> origin/Dev
  type    = string
  default = "private"

  validation {
<<<<<<< HEAD
=======

>>>>>>> origin/Dev
    condition = contains(
      ["private", "public", "internal"],
      lower(var.repository_visibility)
    )

    error_message = "Repository visibility must be private, public or internal."
<<<<<<< HEAD
  }
=======

  }

>>>>>>> origin/Dev
}

variable "required_approving_review_count" {
  type    = number
  default = 1
}

variable "enable_branch_protection" {
  type    = bool
  default = false
}

<<<<<<< HEAD

############################
# GitHub Self-hosted Runners
############################

# Self-hosted runners are no longer managed by this Terraform project.
# GitHub-hosted runners are used by GitHub Actions workflows.


############################
# End
############################
=======
############################
# GitHub self-hosted runners
############################

#variable "enable_github_runners" {
# type    = bool
# default = true
#}

#variable "runner_vmss_name" {
# type    = string
# default = ""
#}

#variable "runner_vm_size" {
# type    = string
# default = "Standard_D2s_v5"
#}

#variable "runner_instance_count" {

# type    = number
# default = 2

# validation {

#  condition = (
#   var.runner_instance_count >= 1 &&
#  var.runner_instance_count <= 20
#)

#error_message = "Runner count must be between 1 and 20."

#}

#}

#variable "runner_ssh_public_key" {
# type = string
#}

#variable "runner_registration_token" {
#  description = "Short-lived GitHub Actions runner registration token (see README)"
#  type        = string
#  sensitive   = true
#  default     = ""
#}

#variable "runner_autoscale_min" {
#  type    = number
#  default = 1

#validation {
# condition     = var.runner_autoscale_min >= 1
#  error_message = "Minimum runner count must be at least 1."
# }
#}

#variable "runner_autoscale_max" {
# type    = number
# default = 5

#}

variable "existing_infra_resource_group_name" {
  description = "Existing Infrastructure Resource Group"
  type        = string
}



#variable "adf_admin_group_object_id" {
#  type = string
#}

#variable "adf_reader_group_object_id" {
#  type = string
#}

#variable "databricks_admin_group_object_id" {
#  type = string
#}

#variable "keyvault_admin_group_object_id" {
#  type = string
#}

#variable "keyvault_secret_admin_group_object_id" {
#  type = string
#}
>>>>>>> origin/Dev
