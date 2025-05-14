resource "azurerm_storage_blob" "Employee-Detail" {
  name                   = "employees_data.xlsx"
  storage_account_name   = azurerm_storage_account.hr_storage.name
  storage_container_name = azurerm_storage_container.hr_container.name
  type                  = "Block"
  source                = "/workspace/files/Employee-Detail.xlsx"
}

resource "azurerm_storage_blob" "Executive_Compensation" {
  name                   = "executive_compensation.xlsx"
  storage_account_name   = azurerm_storage_account.hr_storage.name
  storage_container_name = azurerm_storage_container.hr_container.name
  type                  = "Block"
  source                = "/workspace/files/Executive_Compensation.xlsx"
}
