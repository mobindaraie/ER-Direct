# create a resource group
resource "azurerm_resource_group" "rg" {
  name     = "${var.resrouce_prefix}-rg"
  location = var.location
}

# create a virtual network
resource "azurerm_virtual_network" "vnet" {
  name                = "${var.resrouce_prefix}-vnet"
  address_space       = [var.vnet_cidr]
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

# create private link subnet
resource "azurerm_subnet" "er-direct-kv-pe-subnet" {
  name                 = "${var.resrouce_prefix}-pe-subnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = [var.kv_pe_subnet_cidr]
}

module "er-direct" {
  source                 = "./modules/er-direct"
  er_ports               = var.er_ports
  resource_group_name    = azurerm_resource_group.rg.name
  virtual_network_name   = azurerm_virtual_network.vnet.name
  virtual_network_id     = azurerm_virtual_network.vnet.id
  shared_location        = var.location
  key_vault_pe_subnet_id = azurerm_subnet.er-direct-kv-pe-subnet.id
  resrouce_prefix        = var.resrouce_prefix

}

module "client_vm" {
  source                = "./modules/client-vm"
  count                 = var.create_client_vm ? 1 : 0
  resource_group_name   = azurerm_resource_group.rg.name
  location              = var.location
  virtual_network_name  = azurerm_virtual_network.vnet.name
  client_vm_subnet_cidr = var.client_vm_subnet_cidr

}
