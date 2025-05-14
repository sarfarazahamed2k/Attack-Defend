resource "azurerm_key_vault_secret" "credential" {
  name         = "${var.scenario2_entra_user.user_principal_name}"
  value        = "${var.netbios_name}\\${var.scenario2_entra_user.user_principal_name}:${var.scenario2_entra_user.password}"
  key_vault_id = azurerm_key_vault.kv.id

  depends_on = [
    azurerm_role_assignment.scenario2_user_key_vault_administrator
  ]
}

resource "azurerm_key_vault_secret" "decoy_credential" {
  name         = "${var.scenario2_entra_decoy_user.user_principal_name}"
  value        = "${var.scenario2_entra_decoy_user.user_principal_name}@${data.azuread_domains.current.domains[0].domain_name}:P@ssw0rd1!"
  key_vault_id = azurerm_key_vault.kv.id

  depends_on = [
    azurerm_role_assignment.scenario2_user_key_vault_administrator
  ]
}
