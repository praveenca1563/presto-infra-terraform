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
# Existing Route Tables (Optional)
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