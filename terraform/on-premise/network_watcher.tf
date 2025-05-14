resource "azurerm_network_watcher" "network_watcher" {
  name                = "NetworkWatcher"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_virtual_machine_extension" "win_server_nw" {
  name                       = "network-watcher"
  virtual_machine_id         = azurerm_windows_virtual_machine.win_server.id
  publisher                  = "Microsoft.Azure.NetworkWatcher"
  type                       = "NetworkWatcherAgentWindows"
  type_handler_version       = "1.4"
  auto_upgrade_minor_version = true
}

resource "azurerm_virtual_machine_extension" "win11_nw" {
  name                       = "network-watcher"
  virtual_machine_id         = azurerm_windows_virtual_machine.win11.id
  publisher                  = "Microsoft.Azure.NetworkWatcher"
  type                       = "NetworkWatcherAgentWindows"
  type_handler_version       = "1.4"
  auto_upgrade_minor_version = true
}

# # Packet Capture for Windows Server
# resource "azurerm_virtual_machine_packet_capture" "win_server_capture" {
#   name                                 = "win-server-capture"
#   network_watcher_id                   = azurerm_network_watcher.network_watcher.id
#   virtual_machine_id                   = azurerm_windows_virtual_machine.win_server.id

#   storage_location {
#     storage_account_id = azurerm_storage_account.storage.id
#     file_path         = "win-server-capture.pcap"
#   }

#   depends_on = [azurerm_virtual_machine_extension.win_server_nw]
# }

# # Packet Capture for Windows 11
# resource "azurerm_virtual_machine_packet_capture" "win11_capture" {
#   name                                 = "win11-capture"
#   network_watcher_id                   = azurerm_network_watcher.network_watcher.id
#   virtual_machine_id                   = azurerm_windows_virtual_machine.win11.id

#   storage_location {
#     storage_account_id = azurerm_storage_account.storage.id
#     file_path         = "wi11-capture.pcap"
#   }

#   depends_on = [azurerm_virtual_machine_extension.win11_nw]
# }
# Network Watcher Extension for Windows 11
