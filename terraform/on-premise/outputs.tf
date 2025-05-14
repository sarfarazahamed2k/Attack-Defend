output "windows_server_ip" {
  value = azurerm_public_ip.win_server_pip.ip_address
}

output "windows_11_ip" {
  value = azurerm_public_ip.win11_pip.ip_address
}

output "wazuh_ip" {
  value = azurerm_public_ip.wazuh_pip.ip_address
}

output "portspoof_ip" {
  value = azurerm_public_ip.portspoof_pip.ip_address
}

output "resource_group_name" {
  value = azurerm_resource_group.rg.name
}

output "network_watcher_name" {
  value = azurerm_network_watcher.network_watcher.name
}

output "windows_server_id" {
  value = azurerm_windows_virtual_machine.win_server.id
}

output "windows_11_id" {
  value = azurerm_windows_virtual_machine.win11.id
}

output "storage_account_id" {
  value = azurerm_storage_account.storage.id
}

output "storage_account_name" {
  value = azurerm_storage_account.storage.name
}

output "network_watcher_id" {
  value = azurerm_network_watcher.network_watcher.id
}

output "win_server_id" {
  value = azurerm_windows_virtual_machine.win_server.id
}

output "win11_id" {
  value = azurerm_windows_virtual_machine.win11.id
}

resource "local_file" "ansible_inventory" {
  filename = "${path.module}/inventory.ini"
  content = templatefile("${path.module}/templates/inventory.tftpl", {
    win_server_ip   = azurerm_public_ip.win_server_pip.ip_address
    win11_ip        = azurerm_public_ip.win11_pip.ip_address
    wazuh_ip          = azurerm_public_ip.wazuh_pip.ip_address
    portspoof_ip    = azurerm_public_ip.portspoof_pip.ip_address
    admin_user      = var.admin_username
    admin_password  = var.admin_password
  })
}

resource "local_file" "dc_config" {
  filename = "${path.module}/dc.yml"
  content = templatefile("${path.module}/templates/dc.tftpl", {
    domain_name     = var.domain_name
    safe_mode_password = var.safe_mode_password
    netbios_name    = var.netbios_name
    domain_admin    = var.domain_admin
    domain_admin_password = var.domain_admin_password
    entra_connect_config = var.entra_connect_config
  })
}

resource "local_file" "workstation_config" {
  filename = "${path.module}/workstation.yml"
  content = templatefile("${path.module}/templates/workstation.tftpl", {
    domain_controller_ip   = var.domain_controller_ip
    domain_name           = var.domain_name
    domain_admin          = var.domain_admin
    domain_admin_password = var.domain_admin_password
    workstation_hostname  = var.workstation_hostname
    domain_server        = "${var.netbios_name}-DC.${var.domain_name}"
  })
}

resource "local_file" "scenario1_config" {
  filename = "${path.module}/scenario-1.yml"
  content = templatefile("${path.module}/templates/scenario-1.tftpl", {
    domain_name = var.domain_name
    scenario1_users = var.scenario1_users
    scenario1_config = var.scenario1_config
    domain_admin = var.domain_admin
    domain_admin_password = var.domain_admin_password
  })
}

resource "local_file" "scenario2_config" {
  filename = "${path.module}/scenario-2.yml"
  content = templatefile("${path.module}/templates/scenario-2.tftpl", {
    domain_name = var.domain_name
    scenario2_users = var.scenario2_users
    scenario2_config = var.scenario2_config
    domain_admin = var.domain_admin
    domain_admin_password = var.domain_admin_password
  })
}

resource "local_file" "scenario3_config" {
  filename = "${path.module}/scenario-3.yml"
  content = templatefile("${path.module}/templates/scenario-3.tftpl", {
    domain_name = var.domain_name
    scenario3_users = var.scenario3_users
    scenario3_config = var.scenario3_config
  })
}

resource "local_file" "scenario4_config" {
  filename = "${path.module}/scenario-4.yml"
  content = templatefile("${path.module}/templates/scenario-4.tftpl", {
    domain_name = var.domain_name
    scenario4_users = var.scenario4_users
    spn_users = var.spn_users
    scenario4_config = var.scenario4_config
  })
}
