output "role_assignment_ids" {
  value = {
    for k, v in azurerm_role_assignment.this :
    k => v.id
  }
<<<<<<< HEAD
}

output "assignments" {
  description = "All role assignments created by this module."
  value       = azurerm_role_assignment.this
=======
>>>>>>> origin/Dev
}