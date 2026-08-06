resource "azurerm_virtual_network" "this" {
  name                = var.vnet_name
  address_space       = var.vnet_address_space
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags
}

resource "azurerm_network_security_group" "this" {
  for_each = var.subnets

  name                = each.value.nsg_name
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags

  dynamic "security_rule" {
    for_each = lookup(each.value, "nsg_rules", [])
    content {
      name                       = security_rule.value.name
      priority                   = security_rule.value.priority
      direction                  = security_rule.value.direction
      access                     = security_rule.value.access
      protocol                   = security_rule.value.protocol
      source_port_range          = lookup(security_rule.value, "source_port_range", "*")
      destination_port_range     = lookup(security_rule.value, "destination_port_range", "*")
      source_address_prefix      = lookup(security_rule.value, "source_address_prefix", "*")
      destination_address_prefix = lookup(security_rule.value, "destination_address_prefix", "*")
    }
  }
}

# Route table is treated as existing infrastructure already owned by the network team,
# looked up by name rather than created here, unless var.create_route_table is true.
data "azurerm_route_table" "existing" {
  for_each = var.create_route_table ? {} : { for k, v in var.subnets : k => v if v.route_table_name != null }

  name                = each.value.route_table_name
  resource_group_name = var.resource_group_name
}

resource "azurerm_route_table" "this" {
  for_each = var.create_route_table ? { for k, v in var.subnets : k => v if v.route_table_name != null } : {}

  name                = each.value.route_table_name
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags
}

resource "azurerm_subnet" "this" {
  for_each = var.subnets

  name                 = each.value.name
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.this.name
  address_prefixes     = each.value.address_prefixes

  dynamic "delegation" {
    for_each = lookup(each.value, "delegation", null) != null ? [each.value.delegation] : []
    content {
      name = delegation.value.name
      service_delegation {
        name    = delegation.value.service_name
        actions = delegation.value.actions
      }
    }
  }
}

resource "azurerm_subnet_network_security_group_association" "this" {
  for_each = var.subnets

  subnet_id                 = azurerm_subnet.this[each.key].id
  network_security_group_id = azurerm_network_security_group.this[each.key].id
}

resource "azurerm_subnet_route_table_association" "this" {
  for_each = { for k, v in var.subnets : k => v if v.route_table_name != null }

  subnet_id      = azurerm_subnet.this[each.key].id
  route_table_id = var.create_route_table ? azurerm_route_table.this[each.key].id : data.azurerm_route_table.existing[each.key].id
}
