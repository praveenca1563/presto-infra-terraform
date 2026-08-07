resource "azurerm_role_assignment" "this" {

  for_each = {
    for assignment in var.role_assignments :
    "${assignment.principal_id}-${assignment.role_definition_name}" => assignment
  }

  scope                = var.scope
  role_definition_name = each.value.role_definition_name
  principal_id         = each.value.principal_id
}