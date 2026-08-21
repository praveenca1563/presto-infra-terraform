############################################################
# Existing GitHub Repository
############################################################

data "github_repository" "this" {
  full_name = "${var.github_owner}/${var.repository_name}"
}

############################################################
# Branch Protection
############################################################

resource "github_branch_protection" "main" {
  count = var.enable_branch_protection ? 1 : 0

  repository_id = data.github_repository.this.node_id
  pattern       = var.default_branch

  required_pull_request_reviews {
    required_approving_review_count = var.required_approving_review_count
    dismiss_stale_reviews           = true
  }

  required_status_checks {
    strict   = true
    contexts = var.required_status_check_contexts
  }

  enforce_admins = var.enforce_admins_on_protection
}

############################################################
# GitHub Actions Secrets
############################################################

resource "github_actions_secret" "azure_client_id" {
  repository  = data.github_repository.this.name
  secret_name = "AZURE_CLIENT_ID"
  value       = var.azure_client_id
}

resource "github_actions_secret" "azure_tenant_id" {
  repository  = data.github_repository.this.name
  secret_name = "AZURE_TENANT_ID"
  value       = var.azure_tenant_id
}

resource "github_actions_secret" "azure_subscription_id" {
  repository  = data.github_repository.this.name
  secret_name = "AZURE_SUBSCRIPTION_ID"
  value       = var.azure_subscription_id
}

resource "github_actions_secret" "azure_client_secret" {
  count = var.azure_client_secret != null ? 1 : 0

  repository  = data.github_repository.this.name
  secret_name = "AZURE_CLIENT_SECRET"
  value       = var.azure_client_secret
}