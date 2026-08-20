############################################################
# Existing Virtual Network
############################################################

data "azurerm_virtual_network" "this" {
  name                = var.vnet_name
  resource_group_name = var.resource_group_name
}

############################################################
# Existing Subnets
############################################################

data "azurerm_subnet" "this" {
  for_each = var.subnets

  name                 = each.value.name
  virtual_network_name = data.azurerm_virtual_network.this.name
  resource_group_name  = var.resource_group_name
}

############################################################
# Existing Network Security Groups
############################################################

data "azurerm_network_security_group" "this" {
  for_each = var.subnets

  name                = each.value.nsg_name
  resource_group_name = var.resource_group_name
}

############################################################
# Existing Route Tables
############################################################

data "azurerm_route_table" "this" {
  for_each = {
    for k, v in var.subnets :
    k => v
    if try(v.route_table_name, null) != null
  }

  name                = each.value.route_table_name
  resource_group_name = var.resource_group_name
}

############################################################
# Databricks Public Subnet
# Required Service Endpoint: Microsoft.Storage
############################################################

resource "azapi_update_resource" "databricks_public_service_endpoint" {
  type = "Microsoft.Network/virtualNetworks/subnets@2024-10-01"

  resource_id = data.azurerm_subnet.this["databricks_public"].id

  body = {
    properties = {
      serviceEndpoints = [
        for endpoint in distinct(concat(
          data.azurerm_subnet.this["databricks_public"].service_endpoints,
          ["Microsoft.Storage"]
          )) : {
          service = endpoint
        }
      ]
    }
  }
}

############################################################
# Databricks Private Subnet
# Required Service Endpoint: Microsoft.Storage
############################################################

resource "azapi_update_resource" "databricks_private_service_endpoint" {
  type = "Microsoft.Network/virtualNetworks/subnets@2024-10-01"

  resource_id = data.azurerm_subnet.this["databricks_private"].id

  body = {
    properties = {
      serviceEndpoints = [
        for endpoint in distinct(concat(
          data.azurerm_subnet.this["databricks_private"].service_endpoints,
          ["Microsoft.Storage"]
          )) : {
          service = endpoint
        }
      ]
    }
  }

  depends_on = [
    azapi_update_resource.databricks_public_service_endpoint
  ]
}

############################################################
# Data Subnet
# Required Service Endpoint: Microsoft.KeyVault
############################################################

resource "azapi_update_resource" "data_service_endpoint" {
  type = "Microsoft.Network/virtualNetworks/subnets@2024-10-01"

  resource_id = data.azurerm_subnet.this["data"].id

  body = {
    properties = {
      serviceEndpoints = [
        for endpoint in distinct(concat(
          data.azurerm_subnet.this["data"].service_endpoints,
          ["Microsoft.KeyVault"]
          )) : {
          service = endpoint
        }
      ]
    }
  }

  depends_on = [
    azapi_update_resource.databricks_private_service_endpoint
  ]
}