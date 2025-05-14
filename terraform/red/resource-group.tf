resource "azurerm_resource_group" "rg" {
  name     = "red-team"
  location = var.location
}
