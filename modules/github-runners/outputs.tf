output "vmss_id" {
  value = azurerm_linux_virtual_machine_scale_set.runners.id
}

output "vmss_name" {
  value = azurerm_linux_virtual_machine_scale_set.runners.name
}

output "identity_principal_id" {
  value = azurerm_user_assigned_identity.runner.principal_id
}
