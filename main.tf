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
# Resource Groups
############################################################

module "resource_groups" {
  source = "./modules/resource-group"

  resource_groups = var.resource_groups
  common_tags     = local.common_tags
}

############################################################
# Networking
############################################################

module "networking" {
  source = "./modules/networking"

  vnet_name           = var.vnet_name
  resource_group_name = data.azurerm_resource_group.infra.name
  subnets             = var.subnets

  tags = var.common_tags
}

############################################################
# Key Vault
############################################################

module "key_vault" {
  source = "./modules/key-vault"

  key_vault_name            = var.key_vault_name
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

  storage_account_name = var.storage_account_name
  resource_group_name  = module.resource_groups.resource_group_names[var.data_rg_key]
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

  data_factory_name      = var.data_factory_name
  resource_group_name    = module.resource_groups.resource_group_names[var.data_rg_key]
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

  workspace_name              = var.databricks_workspace_name
  resource_group_name         = module.resource_groups.resource_group_names[var.data_rg_key]
  location                    = var.location
  sku                         = var.databricks_sku
  managed_resource_group_name = var.databricks_managed_rg_name

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

  runner_registration_token = var.enable_github_runners ? var.runner_registration_token : null
}

############################################################
# GitHub Self-Hosted Runners
############################################################

module "github_runners" {
  source = "./modules/github-runners"

  count = var.enable_github_runners ? 1 : 0

  vmss_name           = var.runner_vmss_name != "" ? var.runner_vmss_name : "${var.repository_name}-runners"
  resource_group_name = data.azurerm_resource_group.infra.name
  location            = var.location
  identity_name       = "${var.repository_name}-runner-identity"

  vm_size        = var.runner_vm_size
  instance_count = var.runner_instance_count
  ssh_public_key = var.runner_ssh_public_key
  subnet_id      = module.networking.subnet_ids[var.data_subnet_key]

  github_owner = var.github_owner
  github_repo  = var.repository_name

  runner_registration_token = var.runner_registration_token
  autoscale_min             = var.runner_autoscale_min
  autoscale_max             = var.runner_autoscale_max

  tags = local.common_tags

  depends_on = [
    module.github_repo,
    module.networking
  ]
}

data "azurerm_client_config" "current" {}

module "storage_rbac" {

  source = "./modules/rbac"

  scope = module.storage_account.storage_account_id

  role_assignments = [
    {
      role_definition_name = "Storage Blob Data Contributor"
      principal_id         = data.azurerm_client_config.current.object_id
    }
  ]
}

############################################################
# Storage Account RBAC
############################################################

data "azurerm_client_config" "current" {}

module "storage_rbac" {

  source = "./modules/rbac"

  scope = module.storage_account.storage_account_id

  role_assignments = [

    {
      role_definition_name = "Storage Blob Data Contributor"
      principal_id         = data.azurerm_client_config.current.object_id
    }

  ]

  depends_on = [
    module.storage_account
  ]
}

############################################################
# Data Factory RBAC
############################################################

module "adf_rbac" {

  source = "./modules/rbac"

  scope = module.data_factory.data_factory_id

  role_assignments = [

    {
      role_definition_name = "Data Factory Contributor"
      principal_id         = var.adf_admin_group_object_id
    },

    {
      role_definition_name = "Reader"
      principal_id         = var.adf_reader_group_object_id
    }

  ]

  depends_on = [
    module.data_factory
  ]
}

############################################################
# Databricks RBAC
############################################################

module "databricks_rbac" {

  source = "./modules/rbac"

  scope = module.databricks.workspace_id

  role_assignments = [

    {
      role_definition_name = "Contributor"
      principal_id         = var.databricks_admin_group_object_id
    }

  ]

  depends_on = [
    module.databricks
  ]
}

############################################################
# Key Vault RBAC
############################################################

module "keyvault_rbac" {

  source = "./modules/rbac"

  scope = module.key_vault.key_vault_id

  role_assignments = [

    {
      role_definition_name = "Key Vault Administrator"
      principal_id         = var.keyvault_admin_group_object_id
    },

    {
      role_definition_name = "Key Vault Secrets Officer"
      principal_id         = var.keyvault_secret_admin_group_object_id
    }

  ]

  depends_on = [
    module.key_vault
  ]
}