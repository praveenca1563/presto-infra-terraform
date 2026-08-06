############################################################
# Azure Resource Manager Provider
############################################################

provider "azurerm" {

  features {

    resource_group {
      prevent_deletion_if_contains_resources = false
    }

    key_vault {
      purge_soft_delete_on_destroy    = false
      recover_soft_deleted_key_vaults = true
    }
  }

  subscription_id = var.azure_subscription_id
  tenant_id       = var.azure_tenant_id
  client_id       = var.azure_client_id
  client_secret   = var.azure_client_secret

  skip_provider_registration = false
}

############################################################
# Azure Active Directory Provider
############################################################

provider "azuread" {

  tenant_id     = var.azure_tenant_id
  client_id     = var.azure_client_id
  client_secret = var.azure_client_secret

}

############################################################
# GitHub Provider
############################################################

provider "github" {

  owner = var.github_owner
  token = var.github_token

}