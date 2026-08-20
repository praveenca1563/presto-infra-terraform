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


############################################################
# Current Terraform Identity
############################################################

data "azurerm_client_config" "current" {}


############################################################
# Networking
############################################################

module "networking" {
  source = "./modules/networking"

  providers = {
    azapi = azapi
  }
  vnet_name           = var.vnet_name
  resource_group_name = data.azurerm_resource_group.network.name
  subnets             = var.subnets

  tags = local.common_tags
}


############################################################
# Key Vault
############################################################

module "key_vault" {
  source = "./modules/key-vault"

  key_vault_name            = local.names.key_vault_name
  resource_group_name       = data.azurerm_resource_group.infra.name
  location                  = var.location
  tenant_id                 = var.azure_tenant_id
  allowed_subnet_ids        = [module.networking.subnet_ids[var.data_subnet_key]]
  admin_object_ids          = var.key_vault_admin_object_ids
  secrets_reader_object_ids = var.key_vault_secrets_reader_object_ids

  tags = local.common_tags
}


############################################################
# Storage Account
############################################################

module "storage_account" {
  source = "./modules/storage-account"

  storage_account_name = local.names.storage_account_name
  resource_group_name  = data.azurerm_resource_group.data.name
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
  
}


############################################################
# Azure Data Factory
############################################################

module "data_factory" {
  source = "./modules/data-factory"

  data_factory_name      = local.names.data_factory_name
  resource_group_name    = data.azurerm_resource_group.data.name
  location               = var.location
  public_network_enabled = var.adf_public_network_enabled
  storage_account_id     = module.storage_account.storage_account_id

  contributor_group_object_ids = var.adf_contributor_group_object_ids
  reader_group_object_ids      = var.adf_reader_group_object_ids

  tags = local.common_tags
}


############################################################
# Azure Databricks
############################################################

module "databricks" {
  source = "./modules/databricks"

  workspace_name              = local.names.databricks_workspace_name
  resource_group_name         = data.azurerm_resource_group.data.name
  location                    = var.location
  sku                         = var.databricks_sku
  managed_resource_group_name = local.names.databricks_managed_rg_name

  enable_vnet_injection = true

  vnet_id             = module.networking.vnet_id
  public_subnet_name  = module.networking.subnet_names[var.databricks_public_subnet_key]
  private_subnet_name = module.networking.subnet_names[var.databricks_private_subnet_key]

  public_subnet_nsg_association_id  = module.networking.nsg_ids[var.databricks_public_subnet_key]
  private_subnet_nsg_association_id = module.networking.nsg_ids[var.databricks_private_subnet_key]

  metastore_admin_object_ids = var.databricks_metastore_admin_object_ids

  tags = local.common_tags
}


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

  enable_branch_protection = var.enable_branch_protection
}


############################################################
# RBAC
############################################################

module "rbac" {
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
}