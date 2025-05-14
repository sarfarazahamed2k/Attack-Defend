variable "location" {
 description = "Azure region for resource deployment"
 type        = string
}

resource "azurerm_resource_group" "rg" {
  name     = "entraid-settings"
  location = var.location
}

