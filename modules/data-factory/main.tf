resource "azurerm_data_factory" "this" {
  name                = var.data_factory_name
  location            = var.location
  resource_group_name = var.resource_group_name

  identity {
    type = "SystemAssigned"
  }

  public_network_enabled = var.public_network_enabled


  tags = var.tags
}

# Grants the ADF System Assigned Managed Identity access to the data lake.
resource "azurerm_role_assignment" "adf_storage_contributor" {
  count = 1

  scope                = var.storage_account_id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = azurerm_data_factory.this.identity[0].principal_id
}

resource "azurerm_role_assignment" "adf_storage_reader" {
  count = 1

  scope                = var.storage_account_id
  role_definition_name = "Reader"
  principal_id         = azurerm_data_factory.this.identity[0].principal_id
}

# RBAC on the ADF instance itself for the data engineering AAD group.
resource "azurerm_role_assignment" "de_group_contributor" {
  for_each = toset(var.contributor_group_object_ids)

  scope                = azurerm_data_factory.this.id
  role_definition_name = "Data Factory Contributor"
  principal_id         = each.value
}

resource "azurerm_role_assignment" "de_group_reader" {
  for_each = toset(var.reader_group_object_ids)

  scope                = azurerm_data_factory.this.id
  role_definition_name = "Reader"
  principal_id         = each.value
}

module "adf_rbac" {
  source = "./modules/rbac"

  scope = module.data_factory.data_factory_id

  role_assignments = [
    {
      role_definition_name = "Data Factory Contributor"
      principal_id         = var.adf_admin_group
    }
  ]
}