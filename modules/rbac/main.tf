resource "azurerm_role_assignment" "this" {

  for_each = {
<<<<<<< HEAD

    for index, assignment in var.assignments :

    index => assignment

  }



  scope = each.value.scope

  role_definition_name = each.value.role_definition_name

  principal_id = each.value.principal_id

=======
    for assignment in var.assignments :
    "${assignment.scope}-${assignment.role_definition_name}-${assignment.principal_id}" => assignment
  }

  scope                = each.value.scope
  role_definition_name = each.value.role_definition_name
  principal_id         = each.value.principal_id
>>>>>>> origin/Dev
}