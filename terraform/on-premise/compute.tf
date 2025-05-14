resource "azurerm_windows_virtual_machine" "win_server" {
  name                = "${var.netbios_name}-DC"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  size                = "Standard_D2ls_v5"
  admin_username      = var.admin_username
  admin_password      = var.admin_password
  priority            = "Spot"
  eviction_policy     = "Deallocate"

  network_interface_ids = [
    azurerm_network_interface.win_server_nic.id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2022-Datacenter"
    version   = "latest"
  }

  depends_on = [
    azurerm_network_interface.win_server_nic
  ]
}

resource "azurerm_windows_virtual_machine" "win11" {
  name                = var.workstation_hostname
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  size                = "Standard_D2ls_v5"
  admin_username      = var.admin_username
  admin_password      = var.admin_password
  priority            = "Spot"
  eviction_policy     = "Deallocate"

  network_interface_ids = [
    azurerm_network_interface.win11_nic.id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsDesktop"
    offer     = "Windows-11"
    sku       = "win11-23h2-pro"
    version   = "latest"
  }

  depends_on = [
    azurerm_network_interface.win11_nic
  ]
}

resource "azurerm_linux_virtual_machine" "wazuh" {
  name                = "Wazuh-VM"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  size                = "Standard_D4a_v4"
  admin_username      = var.admin_username
  admin_password      = var.admin_password
  disable_password_authentication = false
  priority            = "Spot"
  eviction_policy     = "Deallocate"

  network_interface_ids = [
    azurerm_network_interface.wazuh_nic.id,
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
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }

  depends_on = [
    azurerm_network_interface.wazuh_nic
  ]
}

resource "azurerm_linux_virtual_machine" "portspoof" {
  name                = "portspoof-VM"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  size                = "Standard_D2ls_v5"
  admin_username      = var.admin_username
  disable_password_authentication = true
  priority            = "Spot"
  eviction_policy     = "Deallocate"

  network_interface_ids = [
    azurerm_network_interface.portspoof_nic.id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  admin_ssh_key {
    username   = var.admin_username
    public_key = var.ssh_public_key
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
    azurerm_network_interface.portspoof_nic
  ]
}

resource "azurerm_virtual_machine_run_command" "win_server_winrm" {
  name               = "win_server_winrm"
  location           = azurerm_resource_group.rg.location
  virtual_machine_id = azurerm_windows_virtual_machine.win_server.id

  depends_on = [
    azurerm_windows_virtual_machine.win_server
  ]

  source {
    script = <<EOT
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
$url = "https://raw.githubusercontent.com/ansible/ansible-documentation/refs/heads/devel/examples/scripts/ConfigureRemotingForAnsible.ps1"
Invoke-WebRequest $url -OutFile C:\Temp\AnsibleWinrmConfig.ps1 -Verbose
Start-Sleep -Seconds 2
C:\temp\AnsibleWinrmConfig.ps1 -EnableCredSSP -Verbose
EOT
  }
}

resource "azurerm_virtual_machine_run_command" "win11_winrm" {
  name               = "win11_winrm"
  location           = azurerm_resource_group.rg.location
  virtual_machine_id = azurerm_windows_virtual_machine.win11.id

  depends_on = [
    azurerm_windows_virtual_machine.win11
  ]

  source {
    script = <<EOT
Get-NetConnectionProfile | Set-NetConnectionProfile -NetworkCategory Private
Enable-PSRemoting -Force
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
$url = "https://raw.githubusercontent.com/ansible/ansible-documentation/refs/heads/devel/examples/scripts/ConfigureRemotingForAnsible.ps1"
Invoke-WebRequest $url -OutFile C:\AnsibleWinrmConfig.ps1 -Verbose
Start-Sleep -Seconds 2
C:\AnsibleWinrmConfig.ps1 -EnableCredSSP -Verbose
EOT
  }
}
