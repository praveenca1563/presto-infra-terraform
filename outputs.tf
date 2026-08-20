<<<<<<< HEAD
=======
output "resource_group_names" {
  value = module.resource_groups.resource_group_names
}

>>>>>>> origin/Dev
output "vnet_id" {
  value = module.networking.vnet_id
}

output "subnet_ids" {
  value = module.networking.subnet_ids
}

output "key_vault_uri" {
  value = module.key_vault.key_vault_uri
}

output "storage_account_name" {
  value = module.storage_account.storage_account_name
}

output "primary_dfs_endpoint" {
  value = module.storage_account.primary_dfs_endpoint
}

output "data_factory_name" {
  value = module.data_factory.data_factory_name
}

output "data_factory_principal_id" {
  value = module.data_factory.principal_id
}

output "databricks_workspace_url" {
  value = module.databricks.workspace_url
}

output "github_repository_html_url" {
  value = module.github_repo.repository_html_url
}
