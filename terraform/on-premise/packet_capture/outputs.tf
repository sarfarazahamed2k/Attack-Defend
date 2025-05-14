output "packet_capture_storage_path_win11" {
  value = azurerm_virtual_machine_packet_capture.win11_capture.storage_location[0].storage_path
}

output "packet_capture_storage_path_win_server" {
  value = azurerm_virtual_machine_packet_capture.win_server_capture.storage_location[0].storage_path
}

output "storage_account_name" {
  value = data.terraform_remote_state.core.outputs.storage_account_name
}

output "resource_group_name" {
  value = data.terraform_remote_state.core.outputs.resource_group_name
}

output "win11_capture_name" {
  value = azurerm_virtual_machine_packet_capture.win11_capture.name
}

output "win_server_capture_name" {
  value = azurerm_virtual_machine_packet_capture.win_server_capture.name
}

output "location" {
  value = data.terraform_remote_state.core.outputs.location
}