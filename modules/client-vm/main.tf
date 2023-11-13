# create a subnet
resource "azurerm_subnet" "client-subnet" {
  name                 = "client-subnet"
  resource_group_name  = var.resource_group_name
  virtual_network_name = var.virtual_network_name
  address_prefixes     = [var.client_vm_subnet_cidr]
}


# create a public IP address
resource "azurerm_public_ip" "publicip" {
  name                = var.resrouce_prefix != "" ? "${var.resrouce_prefix}-pip" : "er-direct-pip"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"
}

# create a network security group
resource "azurerm_network_security_group" "nsg" {
  name                = var.resrouce_prefix != "" ? "${var.resrouce_prefix}-nsg" : "er-direct-nsg"
  location            = var.location
  resource_group_name = var.resource_group_name
}

resource "azurerm_subnet_network_security_group_association" "example" {
  subnet_id                 = azurerm_subnet.client-subnet.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}

# create a network interface
resource "azurerm_network_interface" "er-client-nic" {
  name                = var.resrouce_prefix != "" ? "${var.resrouce_prefix}-nic" : "er-direct-nic"
  location            = var.location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = "er-direct-client-ipconfig"
    subnet_id                     = azurerm_subnet.client-subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.publicip.id
  }
}

# create a virtual machine if create_client_vm is true
resource "azurerm_windows_virtual_machine" "er-client-vm" {
  name                = var.resrouce_prefix != "" ? "${var.resrouce_prefix}-vm" : "er-direct-vm"
  computer_name       = var.resrouce_prefix != "" ? substr("${var.resrouce_prefix}-vm", 0, 15) : "er-direct-vm"
  location            = var.location
  resource_group_name = var.resource_group_name
  size                = var.vm_sku
  admin_username      = var.admin_username
  admin_password      = var.admin_password
  network_interface_ids = [
    azurerm_network_interface.er-client-nic.id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsDesktop"
    offer     = "windows-11"
    sku       = "win11-23h2-pro"
    version   = "latest"
  }
}


