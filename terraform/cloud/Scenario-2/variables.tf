variable "location" {
 description = "Azure region for resource deployment"
 type        = string
}

variable "netbios_name" {
  description = "NetBIOS name for the domain"
  type        = string
}

variable "scenario2_entra_user" {
  description = "Scenario 2 Entra ID user configuration"
  type = object({
    user_principal_name = string
    display_name        = string
    password           = string
  })
}

variable "scenario2_entra_decoy_user" {
  description = "Scenario 2 Entra ID decoy user configuration"
  type = object({
    user_principal_name = string
    display_name        = string
    password           = string
  })
}

