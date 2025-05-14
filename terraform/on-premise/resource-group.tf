resource "azurerm_resource_group" "rg" {
  name     = "on-premise"
  location = var.location
}

data "azurerm_client_config" "current" {}