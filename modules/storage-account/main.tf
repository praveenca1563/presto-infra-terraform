resource "azurerm_storage_account" "this" {
  name                          = var.storage_account_name
  resource_group_name           = var.resource_group_name
  location                      = var.location
  account_tier                  = var.account_tier
  account_replication_type      = var.replication_type
  account_kind                  = "StorageV2"
  is_hns_enabled                = true # required for ADLS Gen2
  min_tls_version               = "TLS1_2"
  public_network_access_enabled = var.public_network_access_enabled

  network_rules {
    default_action             = var.network_default_action
    virtual_network_subnet_ids = var.allowed_subnet_ids
    ip_rules                   = var.allowed_ip_ranges
  }

  blob_properties {
    dynamic "delete_retention_policy" {
      for_each = var.blob_soft_delete_days > 0 ? [1] : []
      content {
        days = var.blob_soft_delete_days
      }
    }
  }

  tags = var.tags
}

resource "azurerm_storage_container" "containers" {
  for_each = toset(var.containers)

  name                  = each.value
  storage_account_name  = azurerm_storage_account.this.name
  container_access_type = "private"
}

# Emulates a "folder" inside a container (e.g. gold/data_management) by writing a
# zero-byte placeholder blob, since ADLS containers have no native empty-folder concept.
resource "azurerm_storage_blob" "folders" {
  for_each = { for f in var.folders : "${f.container}/${f.path}" => f }

  name                   = "${each.value.path}/.keep"
  storage_account_name   = azurerm_storage_account.this.name
  storage_container_name = each.value.container
  type                   = "Block"
  source_content         = ""

  depends_on = [azurerm_storage_container.containers]
}
