output "web_app_ip" {
  value = azurerm_public_ip.web_app_pip.ip_address
}

output "web_app_workspace_name" {
  value = azurerm_log_analytics_workspace.workspace.name
}

resource "local_file" "scenario4_config" {
  filename = "${path.module}/inventory_webapp.ini"
  content = templatefile("${path.module}/templates/inventory_webapp.tftpl", {
    web_app_ip = azurerm_public_ip.web_app_pip.ip_address
    admin_user      = var.admin_username
  })
}

