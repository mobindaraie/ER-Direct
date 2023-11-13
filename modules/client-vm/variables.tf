variable "create_client_vm" {
  type    = bool
  default = false
}

variable "resource_group_name" {
  type = string
}

variable "location" {
  type = string
}

variable "virtual_network_name" {
  type = string
}

variable "client_vm_subnet_cidr" {
  type    = string
  default = "10.0.0.0/24"
}

variable "resrouce_prefix" {
  type    = string
  default = "er-direct-client"
}

variable "admin_username" {
  type    = string
  default = "adminuser"
}

variable "admin_password" {
  type    = string
  default = "P@ssw0rd1234!"
}

variable "vm_sku" {
  type    = string
  default = "Standard_B8ms"
}
