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
