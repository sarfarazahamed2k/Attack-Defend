variable "location" {
 description = "Azure region for resource deployment"
 type        = string
}

variable "scenario1_entra_user" {
  description = "Scenario 1 Entra ID user configuration"
  type = object({
    user_principal_name = string
    display_name        = string
    password           = string
  })
}
