variable "scope" {
  description = "Azure resource ID where RBAC will be assigned"
  type        = string
}

variable "assignments" {
  description = "List of Azure RBAC assignments"

  type = list(object({
    scope                = string
    role_definition_name = string
    principal_id         = string
  }))
}