terraform {
  required_version = ">= 1.6.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.110"
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = "~> 2.53"
    }
    github = {
      source  = "integrations/github"
      version = "~> 6.2"
    }
  }

  backend "azurerm" {
    # Values intentionally omitted here — supplied at `terraform init`
    # time via -backend-config=environments/<env>/backend.hcl so the
    # backend itself is not hardcoded either. See README.md.
  }
}
