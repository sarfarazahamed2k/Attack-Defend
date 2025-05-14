resource "azurerm_network_security_group" "linux_nsg" {
  name                = "linux-nsg"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  security_rule {
    name                       = "allow-ssh"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

    depends_on = [
        azurerm_log_analytics_workspace.workspace
    ]
}

resource "azurerm_network_interface_security_group_association" "web_app_nsg_assoc" {
  network_interface_id      = azurerm_network_interface.web_app_nic.id
  network_security_group_id = azurerm_network_security_group.linux_nsg.id
}
