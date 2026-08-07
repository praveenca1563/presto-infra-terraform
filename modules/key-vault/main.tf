data "azurerm_client_config" "current" {}

resource "azurerm_key_vault" "this" {
  name                          = var.key_vault_name
  location                      = var.location
  resource_group_name           = var.resource_group_name
  tenant_id                     = var.tenant_id
  sku_name                      = var.sku_name
  purge_protection_enabled      = var.purge_protection_enabled
  soft_delete_retention_days    = var.soft_delete_retention_days
  public_network_access_enabled = var.public_network_access_enabled

  network_acls {
    default_action             = var.network_default_action
    bypass                     = "AzureServices"
    virtual_network_subnet_ids = var.allowed_subnet_ids
  }

  tags = var.tags
}

resource "azurerm_role_assignment" "admin" {
  for_each = toset(var.admin_object_ids)

  scope                = azurerm_key_vault.this.id
  role_definition_name = "Key Vault Administrator"
  principal_id         = each.value
}

resource "azurerm_role_assignment" "secrets_user" {
  for_each = toset(var.secrets_reader_object_ids)

  scope                = azurerm_key_vault.this.id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = each.value
}

locals {
  secret_names = toset(keys(nonsensitive(var.secrets)))
}

resource "azurerm_key_vault_secret" "secrets" {
  for_each = local.secret_names

  name         = each.value
  value        = var.secrets[each.value]
  key_vault_id = azurerm_key_vault.this.id

  depends_on = [azurerm_role_assignment.admin]
}
module "keyvault_rbac" {
  source = "../rbac"

  scope = module.key_vault.key_vault_id

  role_assignments = [
    {
      role_definition_name = "Key Vault Secrets Officer"
      principal_id         = data.azurerm_client_config.current.object_id
    }
  ]
}