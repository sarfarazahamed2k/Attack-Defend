resource "azurerm_resource_group" "rg" {
  name     = "hr-department"
  location = var.location
}

data "azuread_domains" "current" {}
