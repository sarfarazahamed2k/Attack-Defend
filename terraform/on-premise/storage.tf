resource "random_integer" "storage_account" {
  min = 100000
  max = 999999
}

# This storage account is created for storing pcap files from packet_capture on windows machines
resource "azurerm_storage_account" "storage" {
  name                     = "onpremisestorage${random_integer.storage_account.result}"
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}
