resource "random_integer" "storage_account" {
  min = 100000
  max = 999999
}

resource "azurerm_storage_account" "hr_storage" {
  name                     = "hrstorage${random_integer.storage_account.result}"
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  blob_properties {
    versioning_enabled = true
  }
}

resource "azurerm_storage_container" "hr_container" {
  name                  = "employee-container"
  storage_account_id  = azurerm_storage_account.hr_storage.id
  container_access_type = "private"
}
