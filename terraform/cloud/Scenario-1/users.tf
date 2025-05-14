resource "azuread_user" "scenario1_user" {
  user_principal_name    = "${var.scenario1_entra_user.user_principal_name}@${data.azuread_domains.current.domains[0].domain_name}"
  display_name           = "${var.scenario1_entra_user.display_name}"
  password               = "${var.scenario1_entra_user.password}"
  force_password_change  = false
}

resource "azurerm_role_assignment" "scenario1_user_storage_blob_contributor" {
  scope                = azurerm_storage_account.hr_storage.id
  role_definition_name = "Storage Blob Data Owner"
  principal_id         = azuread_user.scenario1_user.object_id
}

resource "azurerm_role_assignment" "scenario1_user_storage_account_contributor" {
  scope                = azurerm_storage_account.hr_storage.id
  role_definition_name = "Storage Account Contributor"
  principal_id         = azuread_user.scenario1_user.object_id
}

