resource "github_repository" "this" {
  name        = var.repository_name
  description = var.repository_description
  visibility  = var.visibility

  has_issues   = true
  has_wiki     = false
  has_projects = false
  auto_init    = true
  # vulnerability_alerts = true

  delete_branch_on_merge = true

  dynamic "template" {
    for_each = var.template_repository != null ? [1] : []
    content {
      owner      = var.template_owner
      repository = var.template_repository
    }
  }
}

resource "github_branch_protection" "main" {
  count = var.enable_branch_protection ? 1 : 0

  repository_id = github_repository.this.node_id
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

# Repository secrets used by the CI/CD pipeline to authenticate to Azure.
# Values must be supplied as sensitive TF variables (e.g. via TF_VAR_ env vars
# in your CI runner or a secure secret store) — never hardcoded or committed.
resource "github_actions_secret" "azure_client_id" {
  repository      = github_repository.this.name
  secret_name     = "AZURE_CLIENT_ID"
  value           = var.azure_client_id
}

resource "github_actions_secret" "azure_tenant_id" {
  repository      = github_repository.this.name
  secret_name     = "AZURE_TENANT_ID"
  value           = var.azure_tenant_id
}

resource "github_actions_secret" "azure_subscription_id" {
  repository      = github_repository.this.name
  secret_name     = "AZURE_SUBSCRIPTION_ID"
  value           = var.azure_subscription_id
}

resource "github_actions_secret" "azure_client_secret" {
  count = var.azure_client_secret != null ? 1 : 0

  repository      = github_repository.this.name
  secret_name     = "AZURE_CLIENT_SECRET"
  value           = var.azure_client_secret
}

resource "github_actions_secret" "runner_registration_token" {
  count = var.runner_registration_token != null ? 1 : 0

  repository      = github_repository.this.name
  secret_name     = "RUNNER_REGISTRATION_TOKEN"
  value           = var.runner_registration_token
}
