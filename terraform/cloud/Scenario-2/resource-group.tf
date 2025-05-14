resource "azurerm_resource_group" "rg" {
  name     = "it-keyvault-dev-rg"
  location = var.location
}

data "azurerm_client_config" "current" {}
data "azuread_domains" "current" {}
