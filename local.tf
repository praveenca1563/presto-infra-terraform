############################################################
# Naming Standard
############################################################
#
# Standard pattern for resources created by this project:
#
#   <type-abbr>-<project>-<environment>-<region-abbr>-<instance>
#
# Exceptions:
#   - Storage accounts do not allow hyphens and are capped at 24 chars, so
#     they use:  <project><purpose><environment>
#   - The Databricks-managed resource group nests the workspace's own
#     abbreviation so it reads clearly next to the workspace it belongs to:
#     rg-dbx-<project>-<environment>-managed-<instance>
#
# type-abbr reference (Azure resource type abbreviations used here):
#   rg  = Resource Group
#   kv  = Key Vault
#   adf = Data Factory
#   dbx = Databricks Workspace
#   st  = Storage Account (prefix only; final name has no hyphens)
#
# Every generated name below can still be overridden per-environment by
# setting the corresponding *_name variable explicitly in tfvars — the
# generated value is only used as a fallback when that variable is null.

locals {

  # Short region token, e.g. "Canada Central" -> "cc"
  naming_region_abbr = lookup(
    var.naming_region_abbreviations,
    var.location,
    "region"
  )

  # Lowercased environment token used in every generated name.
  naming_env = lower(var.environment)

  ############################################################
  # Generated Names (naming-standard candidates)
  ############################################################

  generated_names = {

    key_vault_name = join("-", [
      "kv",
      var.naming_project,
      local.naming_env,
      local.naming_region_abbr,
      var.naming_instance,
    ])

    data_factory_name = join("-", [
      "adf",
      var.naming_project,
      local.naming_env,
      local.naming_region_abbr,
      var.naming_instance,
    ])

    databricks_workspace_name = join("-", [
      "dbx",
      var.naming_project,
      local.naming_env,
      local.naming_region_abbr,
      var.naming_instance,
    ])

    databricks_managed_rg_name = join("-", [
      "rg",
      "dbx",
      var.naming_project,
      local.naming_env,
      "managed",
      var.naming_instance,
    ])

    # Storage accounts: lowercase alphanumeric only, no hyphens, <= 24 chars.
    storage_account_name = lower(
      "${var.naming_project}datalake${local.naming_env}${var.naming_instance}"
    )
  }

  ############################################################
  # Effective Names (explicit var override wins, else generated)
  ############################################################

  names = {
    key_vault_name             = coalesce(var.key_vault_name, local.generated_names.key_vault_name)
    data_factory_name          = coalesce(var.data_factory_name, local.generated_names.data_factory_name)
    databricks_workspace_name  = coalesce(var.databricks_workspace_name, local.generated_names.databricks_workspace_name)
    databricks_managed_rg_name = coalesce(var.databricks_managed_rg_name, local.generated_names.databricks_managed_rg_name)
    storage_account_name       = coalesce(var.storage_account_name, local.generated_names.storage_account_name)
  }
}
