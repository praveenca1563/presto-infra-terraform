############################################################
# Environment
############################################################

environment = "dev"
location    = "Canada Central"

common_tags = {
  project     = "presto-dataeng"
  environment = "dev"
  managed_by  = "terraform"
}

############################################################
# Resource Groups
############################################################

resource_groups = {

  data = {
    name     = "rg-presto-dev-de"
    location = "canadacentral"

    tags = {
      workload = "data-platform"
    }
  }
}

data_rg_key                        = "data"
existing_infra_resource_group_name = "prs-dataeng-cc-infra-rg"

############################################################
# Networking
############################################################

vnet_name = "prs-dataeng-cc-core-vnet"

subnets = {

  databricks_public = {
    name             = "prs-dataeng-cc-core-databricks-public-snet"
    nsg_name         = "prs-dataeng-cc-core-databricks-public-nsg"
    route_table_name = "prs-dataeng-cc-core-udr"
  }

  databricks_private = {
    name             = "prs-dataeng-cc-core-databricks-private-snet"
    nsg_name         = "prs-dataeng-cc-core-databricks-private-nsg"
    route_table_name = "prs-dataeng-cc-core-udr"
  }

  data = {
    name             = "prs-dataeng-cc-core-data-snet"
    nsg_name         = "prs-dataeng-cc-core-data-nsg"
    route_table_name = "prs-dataeng-cc-core-udr"
  }

}

databricks_public_subnet_key  = "databricks_public"
databricks_private_subnet_key = "databricks_private"
data_subnet_key               = "data"

############################################################
# Storage (ADLS Gen2)
############################################################

storage_account_name = "prestodatalakedev001"

storage_containers = [
  "raw",
  "bronze",
  "silver",
  "gold"
]

storage_folders = [
  {
    container = "gold"
    path      = "data_management"
  }
]

storage_public_network_access_enabled = true

############################################################
# Azure Data Factory
############################################################

data_factory_name = "adf-presto-dev-cc-001"

# Set to false after Private Endpoints are implemented.
adf_public_network_enabled = true

adf_contributor_group_object_ids = []
adf_reader_group_object_ids      = []

############################################################
# Azure Databricks
############################################################

databricks_workspace_name  = "dbx-presto-dev-001"
databricks_managed_rg_name = "rg-dbx-presto-dev-managed-001"
databricks_sku             = "premium"

databricks_metastore_admin_object_ids = []

############################################################
# Azure Key Vault
############################################################

key_vault_name = "kv-presto-dataeng-dev"

key_vault_admin_object_ids          = []
key_vault_secrets_reader_object_ids = []

############################################################
# GitHub Repository
############################################################

repository_name = "presto-data-platform-infra"

repository_description = "Terraform IaC for the PRESTO Data Platform (DEV)"

repository_visibility = "private"

required_approving_review_count = 1

############################################################
# GitHub Self-hosted Runners
############################################################

enable_github_runners = true

runner_vmss_name = "prs-dataeng-gh-runners"

runner_vm_size = "Standard_D2s_v5"

# Increase if you expect parallel Terraform deployments.
runner_instance_count = 2

runner_autoscale_min = 1
runner_autoscale_max = 5

############################################################
# Sensitive Values
############################################################

# DO NOT place secrets in this file.
#
# Supply these using GitHub Secrets or TF_VAR_* variables:
#
# azure_subscription_id
# azure_tenant_id
# azure_client_id
# azure_client_secret
# github_owner
# github_token
# runner_ssh_public_key
# runner_registration_token