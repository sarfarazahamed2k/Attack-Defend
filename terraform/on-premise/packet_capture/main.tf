data "terraform_remote_state" "core" {
  backend = "local"
  config  = {
    path  = "../../terraform.tfstate"
  }
}

resource "azurerm_virtual_machine_packet_capture" "win_server_capture" {
  name                                 = "win-server-capture"
  network_watcher_id                   = data.terraform_remote_state.core.outputs.network_watcher_id
  virtual_machine_id                   = data.terraform_remote_state.core.outputs.win_server_id

  storage_location {
    storage_account_id = data.terraform_remote_state.core.outputs.storage_account_id
  }

}

resource "azurerm_virtual_machine_packet_capture" "win11_capture" {
  name                                 = "win11-capture"
  network_watcher_id                   = data.terraform_remote_state.core.outputs.network_watcher_id
  virtual_machine_id                   = data.terraform_remote_state.core.outputs.win11_id

  storage_location {
    storage_account_id = data.terraform_remote_state.core.outputs.storage_account_id
  }
}
