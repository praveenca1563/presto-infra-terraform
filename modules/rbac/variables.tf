variable "scope" {
  description = "Azure resource ID where RBAC will be assigned"
  type        = string
}

variable "role_assignments" {
  description = "List of role assignments"
  type = list(object({
    role_definition_name = string
    principal_id         = string
  }))
}