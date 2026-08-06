output "data_factory_id" {
  value = azurerm_data_factory.this.id
}

output "data_factory_name" {
  value = azurerm_data_factory.this.name
}

output "principal_id" {
  description = "System-assigned managed identity principal ID"
  value       = azurerm_data_factory.this.identity[0].principal_id
}
