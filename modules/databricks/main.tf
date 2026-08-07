resource "azurerm_databricks_workspace" "this" {

  name                        = var.workspace_name
  resource_group_name         = var.resource_group_name
  location                    = var.location
  sku                         = var.sku
  managed_resource_group_name = var.managed_resource_group_name

  # public_network_access_enabled = var.public_network_access_enabled
  public_network_access_enabled = false
  no_public_ip                  = true

  dynamic "custom_parameters" {
    for_each = var.enable_vnet_injection ? [1] : []

    content {
      virtual_network_id                                   = var.vnet_id
      public_subnet_name                                   = var.public_subnet_name
      private_subnet_name                                  = var.private_subnet_name
      public_subnet_network_security_group_association_id  = var.public_subnet_nsg_association_id
      private_subnet_network_security_group_association_id = var.private_subnet_nsg_association_id
     #  no_public_ip                                         = var.no_public_ip
    }
  }

  lifecycle {
    prevent_destroy = true
  }

  tags = var.tags
}

############################################################
# Databricks Workspace Administrators
############################################################

resource "azurerm_role_assignment" "metastore_admin" {

  for_each = toset(var.metastore_admin_object_ids)

  scope                = azurerm_databricks_workspace.this.id
  role_definition_name = "Contributor"
  principal_id         = each.value

  depends_on = [
    azurerm_databricks_workspace.this
  ]
}