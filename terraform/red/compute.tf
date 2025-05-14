resource "azurerm_linux_virtual_machine" "attack_vm" {
    name                = "attack-vm"
    resource_group_name = azurerm_resource_group.rg.name
    location            = azurerm_resource_group.rg.location
    size                = "Standard_D4a_v4"
    admin_username      = var.admin_username
    admin_password      = var.admin_password
    disable_password_authentication = false
    priority            = "Spot"
    eviction_policy     = "Deallocate"

    network_interface_ids = [
        azurerm_network_interface.attack_vm_nic.id,
    ]

    admin_ssh_key {
        username   = var.admin_username
        public_key = var.ssh_public_key
    }

    os_disk {
        caching              = "ReadWrite"
        storage_account_type = "Standard_LRS"
    }

    source_image_reference {
        publisher = "kali-linux"
        offer     = "kali"
        sku       = "kali-2024-3"
        version   = "latest"
    }

    plan {
        name      = "kali-2024-3"
        product   = "kali"
        publisher = "kali-linux"
    }

    depends_on = [
    azurerm_network_interface.attack_vm_nic
  ]
}
