data "terraform_remote_state" "core" {
  backend = "local"
  config = {
    path = "../packet_capture/terraform.tfstate"
  }
}

locals {
 captures = [data.terraform_remote_state.core.outputs.win11_capture_name, data.terraform_remote_state.core.outputs.win_server_capture_name]
}

resource "null_resource" "stop_packet_captures" {
 count = length(local.captures)
 provisioner "local-exec" {
   command = "az network watcher packet-capture stop --name ${local.captures[count.index]} --location '${data.terraform_remote_state.core.outputs.location}'"
 }
}

data "azurerm_storage_account" "packet_capture" {
  name                = data.terraform_remote_state.core.outputs.storage_account_name
  resource_group_name = data.terraform_remote_state.core.outputs.resource_group_name
}

# It automatically creates a container named "network-watcher-logs" where all pcap files are stored in a specific directory format
data "azurerm_storage_account_blob_container_sas" "packet_capture" {
  connection_string = data.azurerm_storage_account.packet_capture.primary_connection_string
  container_name    = "network-watcher-logs"
  
  start  = timestamp()
  expiry = timeadd(timestamp(), "1h")  

  permissions {
    read   = true
    add    = false
    create = false
    write  = false
    delete = false
    list   = true
  }
}

data "http" "win11_capture" {
  url = "${data.terraform_remote_state.core.outputs.packet_capture_storage_path_win11}${data.azurerm_storage_account_blob_container_sas.packet_capture.sas}"

  request_headers = {
    Accept = "application/octet-stream"
  }
  depends_on = [null_resource.stop_packet_captures]
}

data "http" "win_server_capture" {
  url = "${data.terraform_remote_state.core.outputs.packet_capture_storage_path_win_server}${data.azurerm_storage_account_blob_container_sas.packet_capture.sas}"

  request_headers = {
    Accept = "application/octet-stream"
  }
  depends_on = [null_resource.stop_packet_captures]
}

resource "local_file" "win11_capture" {
  content_base64 = data.http.win11_capture.response_body_base64
  filename       = "${path.module}/win11_capture.cap"
}

resource "local_file" "win_server_capture" {
  content_base64 = data.http.win_server_capture.response_body_base64
  filename       = "${path.module}/win_server_capture.cap"
}
