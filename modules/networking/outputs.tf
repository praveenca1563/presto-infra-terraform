output "vnet_id" {
  description = "ID of the virtual network"
  value       = azurerm_virtual_network.this.id
}

output "vnet_name" {
  value = azurerm_virtual_network.this.name
}

output "subnet_ids" {
  description = "Map of logical subnet name -> subnet ID"
  value       = { for k, v in azurerm_subnet.this : k => v.id }
}

output "subnet_names" {
  description = "Map of logical subnet name -> subnet actual name"
  value       = { for k, v in azurerm_subnet.this : k => v.name }
}

output "nsg_ids" {
  description = "Map of logical subnet name -> NSG ID"
  value       = { for k, v in azurerm_network_security_group.this : k => v.id }
}
