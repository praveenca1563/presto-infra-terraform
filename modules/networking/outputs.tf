output "vnet_id" {
  description = "Virtual Network ID"
  value       = data.azurerm_virtual_network.this.id
}

output "vnet_name" {
  description = "Virtual Network Name"
  value       = data.azurerm_virtual_network.this.name
}

output "subnet_ids" {
  description = "Subnet IDs"
  value = {
    for k, v in data.azurerm_subnet.this :
    k => v.id
  }
}

output "subnet_names" {
  description = "Subnet Names"
  value = {
    for k, v in data.azurerm_subnet.this :
    k => v.name
  }
}

output "nsg_ids" {
  description = "Network Security Group IDs"
  value = {
    for k, v in data.azurerm_network_security_group.this :
    k => v.id
  }
}