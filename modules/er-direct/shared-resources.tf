data "azurerm_client_config" "current" {}

resource "random_integer" "kv-id" {
  min = 100
  max = 999
}

resource "azurerm_key_vault" "er-kv" {
  name                          = substr("${var.resrouce_prefix}-kv-${random_integer.kv-id.result}", 0, 24)
  resource_group_name           = var.resource_group_name
  location                      = var.shared_location
  enabled_for_disk_encryption   = true
  tenant_id                     = data.azurerm_client_config.current.tenant_id
  soft_delete_retention_days    = 7
  purge_protection_enabled      = false
  sku_name                      = "standard"
  enable_rbac_authorization     = true
  public_network_access_enabled = false
  network_acls {
    default_action = "Deny"
    bypass         = "AzureServices"
  }
}

# role assignment to key vault using azurerm_role_assignment
resource "azurerm_role_assignment" "rbac-admin" {
  scope                = azurerm_key_vault.er-kv.id
  role_definition_name = "Key Vault Secrets Officer"
  principal_id         = data.azurerm_client_config.current.object_id
}


# create private endpoint for key vault
resource "azurerm_private_endpoint" "er-direct-pe" {
  name                = var.resrouce_prefix != "" ? "${var.resrouce_prefix}-pe" : "er-direct-pe"
  location            = var.shared_location
  resource_group_name = var.resource_group_name
  subnet_id           = var.key_vault_pe_subnet_id

  private_service_connection {
    name                           = "er-direct-pe-connection"
    private_connection_resource_id = azurerm_key_vault.er-kv.id
    subresource_names              = ["vault"]
    is_manual_connection           = false
  }

  private_dns_zone_group {
    name                 = "er-direct-pe-dns"
    private_dns_zone_ids = [azurerm_private_dns_zone.vault-dns-zone.id]
  }
}

resource "azurerm_private_dns_zone" "vault-dns-zone" {
  name                = "privatelink.vaultcore.azure.net"
  resource_group_name = var.resource_group_name
}

resource "azurerm_private_dns_zone_virtual_network_link" "example" {
  name                  = "er-direct-pe-dns-link"
  resource_group_name   = var.resource_group_name
  private_dns_zone_name = azurerm_private_dns_zone.vault-dns-zone.name
  virtual_network_id    = var.virtual_network_id
  registration_enabled  = false
}
