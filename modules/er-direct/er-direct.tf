resource "azurerm_user_assigned_identity" "er-id" {
  for_each            = var.er_ports
  name                = "${each.key}-identity"
  resource_group_name = var.resource_group_name
  location            = var.shared_location
}

resource "azurerm_express_route_port" "er-directs" {
  for_each            = var.er_ports
  name                = each.key
  resource_group_name = var.resource_group_name
  location            = lookup(each.value, "location")
  peering_location    = lookup(each.value, "peering_location")
  bandwidth_in_gbps   = lookup(each.value, "bandwidth")
  encapsulation       = lookup(each.value, "encapsulation")
  link1 {
    admin_enabled = false
  }
  link2 {
    admin_enabled = false
  }
  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.er-id[each.key].id]
  }
}

resource "azurerm_role_assignment" "rbac-er-id" {
  for_each             = var.er_ports
  scope                = azurerm_key_vault.er-kv.id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = azurerm_user_assigned_identity.er-id[each.key].principal_id
}
