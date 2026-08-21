############################################################
# Storage Account
############################################################

resource "azurerm_storage_account" "this" {
  name                     = var.storage_account_name
  resource_group_name      = var.resource_group_name
  location                 = var.location
  account_tier             = var.account_tier
  account_replication_type = var.replication_type

  account_kind = "StorageV2"

  is_hns_enabled = true

  min_tls_version            = "TLS1_2"
  https_traffic_only_enabled = true

  public_network_access_enabled = var.public_network_access_enabled

  network_rules {
    default_action             = var.network_default_action
    ip_rules                   = var.allowed_ip_ranges
    virtual_network_subnet_ids = var.allowed_subnet_ids
  }

  blob_properties {
    delete_retention_policy {
      days = var.blob_soft_delete_days
    }
  }

  tags = var.tags
}

############################################################
# Storage Containers
############################################################

resource "azurerm_storage_container" "containers" {
  for_each = toset(var.containers)

  name                  = each.value
  storage_account_id    = azurerm_storage_account.this.id
  container_access_type = "private"
}
