variable "repository_name" {
  type = string
}

variable "repository_description" {
  type    = string
  default = ""
}

variable "visibility" {
  description = "public, private, or internal"
  type        = string
  default     = "private"
}

variable "template_owner" {
  type    = string
  default = null
}

variable "template_repository" {
  type    = string
  default = null
}

variable "default_branch" {
  type    = string
  default = "main"
}

variable "enable_branch_protection" {
  description = "Enable GitHub branch protection"
  type        = bool
  default     = false
}

variable "required_approving_review_count" {
  type    = number
  default = 1
}

variable "required_status_check_contexts" {
  type    = list(string)
  default = ["terraform-plan"]
}

variable "enforce_admins_on_protection" {
  type    = bool
  default = false
}

variable "azure_client_id" {
  type      = string
  sensitive = true
}

variable "azure_tenant_id" {
  type      = string
  sensitive = true
}

variable "azure_subscription_id" {
  type      = string
  sensitive = true
}

variable "azure_client_secret" {
  description = "Azure SP client secret. Supply via TF_VAR_azure_client_secret env var — never commit to a .tfvars file."
  type        = string
  sensitive   = true
  default     = null
}

variable "github_owner" {
  description = "GitHub organization or user owning the repository"
  type        = string
}

