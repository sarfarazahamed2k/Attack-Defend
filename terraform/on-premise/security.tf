resource "azurerm_network_security_group" "windows_nsg" {
  name                = "windows-nsg"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  security_rule {
    name                       = "allow-rdp"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3389"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "allow-winrm"
    priority                   = 1002
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "5986"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "allow-winrm-http"
    priority                   = 1003
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "5985"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "allow-wireguard"
    priority                   = 1004
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Udp"
    source_port_range          = "*"
    destination_port_range     = "51820"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

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

  security_rule {
    name                       = "allow-rdp"
    priority                   = 1002
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3389"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_network_interface_security_group_association" "win_server_nsg_assoc" {
  network_interface_id      = azurerm_network_interface.win_server_nic.id
  network_security_group_id = azurerm_network_security_group.windows_nsg.id
}

resource "azurerm_network_interface_security_group_association" "win11_nsg_assoc" {
  network_interface_id      = azurerm_network_interface.win11_nic.id
  network_security_group_id = azurerm_network_security_group.windows_nsg.id
}

resource "azurerm_network_interface_security_group_association" "wazuh_nsg_assoc" {
  network_interface_id      = azurerm_network_interface.wazuh_nic.id
  network_security_group_id = azurerm_network_security_group.linux_nsg.id
}

resource "azurerm_network_interface_security_group_association" "portspoof_nsg_assoc" {
  network_interface_id      = azurerm_network_interface.portspoof_nic.id
  network_security_group_id = azurerm_network_security_group.linux_nsg.id
}
