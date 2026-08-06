output "storage_account_id" {
  value = azurerm_storage_account.this.id
}

output "storage_account_name" {
  value = azurerm_storage_account.this.name
}

output "primary_dfs_endpoint" {
  description = "ADLS Gen2 (dfs) endpoint, used e.g. as Databricks/ADF metastore root"
  value       = azurerm_storage_account.this.primary_dfs_endpoint
}

output "container_ids" {
  value = { for k, v in azurerm_storage_container.containers : k => v.id }
}
