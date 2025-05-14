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

variable "domain_name" {
  description = "The domain name for the environment"
  type        = string
  default     = "csrp.local"
}

variable "domain_controller_ip" {
  description = "IP address of the domain controller"
  type        = string
}

variable "domain_admin" {
  description = "Domain administrator username"
  type        = string
}

variable "domain_admin_password" {
  description = "Domain administrator password"
  type        = string
  sensitive   = true
}

variable "safe_mode_password" {
  description = "Safe mode administrator password"
  type        = string
  sensitive   = true
}

variable "netbios_name" {
  description = "NetBIOS name for the domain"
  type        = string
}

variable "workstation_hostname" {
  description = "Hostname for the workstation"
  type        = string
}

variable "scenario1_users" {
  description = "Users for scenario 1"
  type = list(object({
    username     = string
    description  = string
    display_name = string
    password     = string
    ou           = string
    groups       = list(string)
  }))
}

variable "scenario2_users" {
  description = "Users for scenario 2"
  type = list(object({
    username     = string
    description  = string
    display_name = string
    password     = string
    ou           = string
    groups       = list(string)
  }))
}

variable "scenario3_users" {
  description = "Users for scenario 3"
  type = list(object({
    username     = string
    description  = string
    display_name = string
    password     = string
    ou           = string
    groups       = list(string)
  }))
}

variable "scenario4_users" {
  description = "Users for scenario 4"
  type = list(object({
    username     = string
    description  = string
    display_name = string
    password     = string
    ou           = string
    groups       = list(string)
  }))
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

variable "entra_connect_config" {
  description = "Microsoft Entra Connect configuration"
  type = object({
    username     = string
    display_name = string
    password     = string
  })
}

variable "scenario1_config" {
  description = "Additional configuration for scenario 1"
  type = object({
    users               = list(string)
    group               = string
    chrome_installer_url = string
    temp_path           = string
  })
}

variable "scenario2_config" {
  description = "Additional configuration for scenario 2"
  type = object({
    users = list(string)
    group = string
  })
}

variable "scenario3_config" {
  description = "Additional configuration for scenario 3"
  type = object({
    users                           = list(string)
    group                           = string
    decoy_username                  = string
    unconstrained_delegation_username = string
  })
}

variable "scenario4_config" {
  description = "Additional configuration for scenario 4"
  type = object({
    users = list(string)
    group = string
  })
}
