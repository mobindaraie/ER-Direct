variable "resource_group_name" {
  type = string
}

variable "virtual_network_name" {
  type = string
}

variable "virtual_network_id" {
  type = string
}

variable "resrouce_prefix" {
  type    = string
  default = "er-direct"
}

variable "er_ports" {
  description = <<-EOF
    Map of ER Direct ports to be created
    
    Example:
    {
      er-direct-westus = {
        location = "WestUS" 
        peering_location = "CoreSite-Santa-Clara-SV7"
        encapsulation = "QinQ"
        bandwidth = 10
      }
      er-direct-westcentral = {
        location = "westcentralus"
        peering_location = "CoreSite-Denver-DE1"
        encapsulation = "QinQ"
        bandwidth = 100
      }
    }
  EOF
  type        = map(any)
}

variable "key_vault_pe_subnet_id" {
  description = "The subnet for the key vault"
  type        = string
}

variable "shared_location" {
  description = "The location/region where the shared services for ER including Key Vault will be created "
  type        = string
  default     = "WestUS"
}
