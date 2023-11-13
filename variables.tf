variable "location" {
  description = "The location/region where the ER Direct will be deployed"
  type        = string
  default     = "westcentralus"
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

variable "resrouce_prefix" {
  description = "The ER Direct name"
  type        = string
}

# vnet to host client vm and private endpoint for Key Vault
variable "vnet_cidr" {
  type = string
}

variable "kv_pe_subnet_cidr" {
  type = string
}

variable "create_client_vm" {
  type    = bool
  default = false
}

variable "client_vm_subnet_cidr" {
  type = string
}



