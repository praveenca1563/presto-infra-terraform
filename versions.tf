terraform {

  required_version = ">= 1.6.6"

  required_providers {

    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.80.0"
    }

    azuread = {
      source  = "hashicorp/azuread"
      version = "~> 3.9"
    }

    github = {
      source  = "integrations/github"
      version = "~> 6.4"
    }

    random = {
      source  = "hashicorp/random"
      version = "~> 3.6"
    }

    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0"
    }

    local = {
      source  = "hashicorp/local"
      version = "~> 2.5"
    }
  }
}