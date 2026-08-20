############################################################
# Local Values
############################################################

locals {
  common_tags = merge(
    {
      Environment = var.environment
      ManagedBy   = "Terraform"
      Project     = "PRESTO"
      Repository  = var.repository_name
    },
    var.common_tags
  )
}


############################################################
# Existing Infrastructure Resource Group
############################################################

data "azurerm_resource_group" "infra" {
  name = var.existing_infra_resource_group_name
}

<<<<<<< HEAD

############################################################
# Existing Data Resource Group
############################################################

data "azurerm_resource_group" "data" {
  name = var.existing_data_resource_group_name
}

############################################################
# Existing Network Resource Group
############################################################

data "azurerm_resource_group" "network" {
  name = var.existing_network_resource_group_name
}


=======
>>>>>>> origin/Dev
############################################################
# Current Terraform Identity
############################################################

data "azurerm_client_config" "current" {}

<<<<<<< HEAD
=======
############################################################
# Resource Groups
############################################################

module "resource_groups" {
  source = "./modules/resource-group"

  resource_groups = var.resource_groups
  common_tags     = local.common_tags
}
>>>>>>> origin/Dev

############################################################
# Networking
############################################################

module "networking" {
  source = "./modules/networking"

<<<<<<< HEAD
  providers = {
    azapi = azapi
  }
  vnet_name           = var.vnet_name
  resource_group_name = data.azurerm_resource_group.network.name
  subnets             = var.subnets

  tags = local.common_tags
}


=======
  vnet_name           = var.vnet_name
  resource_group_name = data.azurerm_resource_group.infra.name
  subnets             = var.subnets

  tags = var.common_tags
}

>>>>>>> origin/Dev
############################################################
# Key Vault
############################################################

module "key_vault" {
  source = "./modules/key-vault"

<<<<<<< HEAD
  key_vault_name            = local.names.key_vault_name
=======
  key_vault_name            = var.key_vault_name
>>>>>>> origin/Dev
  resource_group_name       = data.azurerm_resource_group.infra.name
  location                  = var.location
  tenant_id                 = var.azure_tenant_id
  allowed_subnet_ids        = [module.networking.subnet_ids[var.data_subnet_key]]
  admin_object_ids          = var.key_vault_admin_object_ids
  secrets_reader_object_ids = var.key_vault_secrets_reader_object_ids

  tags = local.common_tags
}

<<<<<<< HEAD

=======
>>>>>>> origin/Dev
############################################################
# Storage Account
############################################################

module "storage_account" {
  source = "./modules/storage-account"

<<<<<<< HEAD
  storage_account_name = local.names.storage_account_name
  resource_group_name  = data.azurerm_resource_group.data.name
=======
  storage_account_name = var.storage_account_name
  resource_group_name  = module.resource_groups.resource_group_names[var.data_rg_key]
>>>>>>> origin/Dev
  location             = var.location

  containers = var.storage_containers
  folders    = var.storage_folders

  public_network_access_enabled = var.storage_public_network_access_enabled

  allowed_subnet_ids = [
    module.networking.subnet_ids[var.databricks_public_subnet_key],
    module.networking.subnet_ids[var.databricks_private_subnet_key],
    module.networking.subnet_ids[var.data_subnet_key],
  ]

  tags = local.common_tags
<<<<<<< HEAD
  
}


=======
}

>>>>>>> origin/Dev
############################################################
# Azure Data Factory
############################################################

module "data_factory" {
  source = "./modules/data-factory"

<<<<<<< HEAD
  data_factory_name      = local.names.data_factory_name
  resource_group_name    = data.azurerm_resource_group.data.name
=======
  data_factory_name      = var.data_factory_name
  resource_group_name    = module.resource_groups.resource_group_names[var.data_rg_key]
>>>>>>> origin/Dev
  location               = var.location
  public_network_enabled = var.adf_public_network_enabled
  storage_account_id     = module.storage_account.storage_account_id

  contributor_group_object_ids = var.adf_contributor_group_object_ids
  reader_group_object_ids      = var.adf_reader_group_object_ids

  tags = local.common_tags
}

<<<<<<< HEAD

=======
>>>>>>> origin/Dev
############################################################
# Azure Databricks
############################################################

module "databricks" {
  source = "./modules/databricks"

<<<<<<< HEAD
  workspace_name              = local.names.databricks_workspace_name
  resource_group_name         = data.azurerm_resource_group.data.name
  location                    = var.location
  sku                         = var.databricks_sku
  managed_resource_group_name = local.names.databricks_managed_rg_name
=======
  workspace_name              = var.databricks_workspace_name
  resource_group_name         = module.resource_groups.resource_group_names[var.data_rg_key]
  location                    = var.location
  sku                         = var.databricks_sku
  managed_resource_group_name = var.databricks_managed_rg_name
>>>>>>> origin/Dev

  enable_vnet_injection = true

  vnet_id             = module.networking.vnet_id
  public_subnet_name  = module.networking.subnet_names[var.databricks_public_subnet_key]
  private_subnet_name = module.networking.subnet_names[var.databricks_private_subnet_key]

  public_subnet_nsg_association_id  = module.networking.nsg_ids[var.databricks_public_subnet_key]
  private_subnet_nsg_association_id = module.networking.nsg_ids[var.databricks_private_subnet_key]

  metastore_admin_object_ids = var.databricks_metastore_admin_object_ids

  tags = local.common_tags
}

<<<<<<< HEAD

=======
>>>>>>> origin/Dev
############################################################
# GitHub Repository
############################################################

module "github_repo" {
  source = "./modules/github-repo"

  repository_name                 = var.repository_name
  repository_description          = var.repository_description
  visibility                      = var.repository_visibility
  required_approving_review_count = var.required_approving_review_count

  azure_client_id       = var.azure_client_id
  azure_tenant_id       = var.azure_tenant_id
  azure_subscription_id = var.azure_subscription_id
  azure_client_secret   = var.azure_client_secret

<<<<<<< HEAD
  enable_branch_protection = var.enable_branch_protection
}


############################################################
# RBAC
############################################################

module "rbac" {
=======
  #runner_registration_token = var.enable_github_runners ? var.runner_registration_token : null
  enable_branch_protection = var.enable_branch_protection
}

############################################################
# GitHub Self-Hosted Runners
############################################################

# module "github_runners" {
# source = "./modules/github-runners"

#count = var.enable_github_runners ? 1 : 0

#vmss_name           = var.runner_vmss_name != "" ? var.runner_vmss_name : "${var.repository_name}-runners"
#resource_group_name = data.azurerm_resource_group.infra.name
#location            = var.location
#identity_name       = "${var.repository_name}-runner-identity"

#vm_size        = var.runner_vm_size
#instance_count = var.runner_instance_count
#ssh_public_key = var.runner_ssh_public_key
#subnet_id      = module.networking.subnet_ids[var.data_subnet_key]

#github_owner = var.github_owner
#github_repo  = var.repository_name

#runner_registration_token = var.runner_registration_token
#autoscale_min             = var.runner_autoscale_min
#autoscale_max             = var.runner_autoscale_max

#tags = local.common_tags

#depends_on = [
# module.github_repo,
#module.networking
#]
#}


############################################################
#  RBAC
############################################################

module "rbac" {

>>>>>>> origin/Dev
  source = "./modules/rbac"

  assignments = concat(

    [
      for id in var.adf_contributor_group_object_ids : {
        scope                = module.data_factory.data_factory_id
        role_definition_name = "Data Factory Contributor"
        principal_id         = id
      } if trimspace(id) != ""
    ],

    [
      for id in var.adf_reader_group_object_ids : {
        scope                = module.data_factory.data_factory_id
        role_definition_name = "Reader"
        principal_id         = id
      } if trimspace(id) != ""
    ],

    [
      for id in var.databricks_metastore_admin_object_ids : {
        scope                = module.databricks.workspace_id
        role_definition_name = "Contributor"
        principal_id         = id
      } if trimspace(id) != ""
    ],

    [
      for id in var.key_vault_admin_object_ids : {
        scope                = module.key_vault.key_vault_id
        role_definition_name = "Key Vault Administrator"
        principal_id         = id
      } if trimspace(id) != ""
    ],

    [
      for id in var.key_vault_secrets_reader_object_ids : {
        scope                = module.key_vault.key_vault_id
        role_definition_name = "Key Vault Secrets User"
        principal_id         = id
      } if trimspace(id) != ""
    ],

    [
      {
        scope                = module.storage_account.storage_account_id
        role_definition_name = "Storage Blob Data Contributor"
        principal_id         = data.azurerm_client_config.current.object_id
      }
    ]
  )

  depends_on = [
    module.storage_account,
    module.key_vault,
    module.data_factory,
    module.databricks
  ]
<<<<<<< HEAD
}
=======
}

>>>>>>> origin/Dev
