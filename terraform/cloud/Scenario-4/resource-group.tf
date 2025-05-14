resource "azurerm_resource_group" "rg" {
  name     = "webapp"
  location = var.location
}

data "azuread_domains" "current" {}
