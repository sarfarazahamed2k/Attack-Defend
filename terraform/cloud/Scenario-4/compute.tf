resource "azurerm_linux_virtual_machine" "web_app_vm" {
  name                = "web-app-vm"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  size                = "Standard_D2ls_v5"
  admin_username      = var.admin_username
  admin_password      = var.admin_password
  disable_password_authentication = false
  priority            = "Spot"
  eviction_policy     = "Deallocate"

  network_interface_ids = [
    azurerm_network_interface.web_app_nic.id,
  ]

  identity {
    type = "SystemAssigned"
  }

  admin_ssh_key {
    username   = var.admin_username
    public_key = var.ssh_public_key
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }

  depends_on = [
    azurerm_network_interface.web_app_nic
  ]
}

resource "azurerm_virtual_machine_run_command" "web_app_vm_cred" {
  name               = "web-app-vm-cred"
  location           = azurerm_resource_group.rg.location
  virtual_machine_id = azurerm_linux_virtual_machine.web_app_vm.id
  source {
    script = "echo '${var.scenario4_entra_decoy_user.user_principal_name}@${data.azuread_domains.current.domains[0].domain_name}:P@ssw0rd1!' > /password.txt"
  }
}
