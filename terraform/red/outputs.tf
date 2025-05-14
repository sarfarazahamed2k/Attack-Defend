output "attack_vm_ip" {
  value = azurerm_public_ip.attack_vm_pip.ip_address
}

output "default_frontdoor_domain" {
  value = azurerm_cdn_frontdoor_endpoint.default_endpoint.host_name
}

resource "local_file" "ansible_inventory" {
  filename = "${path.module}/inventory_red.ini"
  content = templatefile("${path.module}/templates/inventory_red.tftpl", {
    attack_vm_ip   = azurerm_public_ip.attack_vm_pip.ip_address
    admin_user      = var.admin_username
    default_frontdoor_domain = azurerm_cdn_frontdoor_endpoint.default_endpoint.host_name

  })
}

