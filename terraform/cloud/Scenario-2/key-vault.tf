resource "random_integer" "key_vault_random" {
    min = 100000
    max = 999999
}

resource "azurerm_key_vault" "kv" {
    name                = "IT-KeyVault-Dev-${random_integer.key_vault_random.result}"
    location            = var.location
    resource_group_name = azurerm_resource_group.rg.name
    tenant_id          = data.azurerm_client_config.current.tenant_id
    sku_name           = "standard"
    enable_rbac_authorization = true
}
