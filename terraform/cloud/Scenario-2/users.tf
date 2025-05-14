resource "azuread_user" "scenario2_user" {
  user_principal_name    = "${var.scenario2_entra_user.user_principal_name}@${data.azuread_domains.current.domains[0].domain_name}"
  display_name           = "${var.scenario2_entra_user.display_name}"
  password               = "${var.scenario2_entra_user.password}"
  force_password_change  = false
}

resource "azurerm_role_assignment" "scenario2_user_key_vault_administrator" {
  scope                = azurerm_key_vault.kv.id
  role_definition_name = "Key Vault Administrator"
  principal_id         = azuread_user.scenario2_user.object_id

  depends_on = [
    azuread_user.scenario2_user,
    azurerm_key_vault.kv
  ]
}

resource "azuread_user" "scenario2_decoy_user" {
  user_principal_name    = "${var.scenario2_entra_decoy_user.user_principal_name}@${data.azuread_domains.current.domains[0].domain_name}"
  display_name           = "${var.scenario2_entra_decoy_user.display_name}"
  password               = "${var.scenario2_entra_decoy_user.password}"
  force_password_change  = false
}

resource "azuread_directory_role" "global_admin" {
  display_name = "Global Administrator"
}

resource "azuread_directory_role_assignment" "scenario2_decoy_user_global_admin" {
  role_id             = azuread_directory_role.global_admin.template_id
  principal_object_id = azuread_user.scenario2_decoy_user.object_id
}
