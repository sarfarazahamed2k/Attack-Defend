variable "admin_username" {
  description = "Administrator username for the VMs"
  type        = string
}

variable "admin_password" {
  description = "Administrator password for the VMs"
  type        = string
  sensitive   = true
}

variable "ssh_public_key" {
  description = "SSH public key for Linux VM authentication"
  type        = string
}

variable "location" {
 description = "Azure region for resource deployment"
 type        = string
}

variable "scenario4_entra_decoy_user" {
  description = "Scenario 4 Entra ID decoy user configuration"
  type = object({
    user_principal_name = string
    display_name        = string
    password           = string
  })
}

variable "spn_users" {
  description = "Service Principal Name users"
  type = list(object({
    display_name = string
    username     = string
    password     = string
    ou           = string
    mssql_spn    = string
  }))
}

