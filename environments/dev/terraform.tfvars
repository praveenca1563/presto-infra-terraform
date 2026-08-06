environment = "nonprod"
location    = "canadacentral"

common_tags = {
  project     = "presto-dataeng"
  environment = "nonprod"
  managed_by  = "terraform"
}

# --- Resource groups (from DetailsInfra.txt) ---
resource_groups = {
  infra = {
    name     = "prs-dataeng-cc-infra-rg"
    location = "canadacentral"
  }
  data = {
    name     = "rg-presto-nonprod-de"
    location = "canadacentral"
  }
}
infra_rg_key = "infra"
data_rg_key  = "data"

# --- Networking (from DetailsInfra.txt) ---
vnet_name           = "prs-dataeng-cc-core-vnet"
vnet_address_space   = ["172.19.204.0/22"]
create_route_table   = false # prs-dataeng-cc-core-udr is owned by the network team; looked up, not created

subnets = {
  databricks_public = {
    name              = "prs-dataeng-cc-core-databricks-public-snet"
    address_prefixes  = ["172.19.204.0/24"]
    nsg_name          = "prs-dataeng-cc-core-databricks-public-nsg"
    route_table_name  = "prs-dataeng-cc-core-udr"
  }
  databricks_private = {
    name              = "prs-dataeng-cc-core-databricks-private-snet"
    address_prefixes  = ["172.19.205.0/24"]
    nsg_name          = "prs-dataeng-cc-core-databricks-private-nsg"
    route_table_name  = "prs-dataeng-cc-core-udr"
  }
  data = {
    name              = "prs-dataeng-cc-core-data-snet"
    address_prefixes  = ["172.19.206.0/24"]
    nsg_name          = "prs-dataeng-cc-core-data-nsg"
    route_table_name  = "prs-dataeng-cc-core-udr"
  }
}

databricks_public_subnet_key  = "databricks_public"
databricks_private_subnet_key = "databricks_private"
data_subnet_key                 = "data"

# --- Storage (ADLS Gen2) ---
storage_account_name = "prestodatalakedev001"
storage_containers     = ["raw", "bronze", "silver", "gold"]
storage_folders         = [{ container = "gold", path = "data_management" }]
storage_public_network_access_enabled = false

# --- Data Factory ---
data_factory_name           = "adf-presto-dev-cc-001"
adf_public_network_enabled = true # per doc: disable once private endpoint is active

# --- Databricks ---
databricks_workspace_name = "dbx-presto-dev-001"
databricks_managed_rg_name = "rg-dbx-presto-dev-managed-001"
databricks_sku               = "premium"

# --- Key Vault ---
key_vault_name = "kv-presto-dataeng-dev"

# --- GitHub repository ---
repository_name        = "presto-data-platform-infra"
repository_description = "Terraform IaC for the PRESTO Data Platform (DEV) - ADLS Gen2, ADF, Databricks, networking, and CI/CD runners"
repository_visibility    = "private"

# --- GitHub self-hosted runners ---
enable_github_runners = true
runner_vmss_name        = "prs-dataeng-gh-runners"
runner_vm_size            = "Standard_D2s_v5"
runner_instance_count   = 2
runner_autoscale_min    = 1
runner_autoscale_max    = 5

# --- Sensitive values: DO NOT put these here. Supply via TF_VAR_ environment
# variables, a CI/CD secret store, or -var on the command line:
#   azure_subscription_id, azure_tenant_id, azure_client_id, azure_client_secret,
#   github_owner, github_token, runner_ssh_public_key, runner_registration_token
# See README.md "Secrets & credentials" section.
