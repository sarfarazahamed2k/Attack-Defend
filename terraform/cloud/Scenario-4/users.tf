data "azurerm_subscription" "current" {}

resource "azuread_user" "scenario4_decoy_user" {
  user_principal_name    = "${var.scenario4_entra_decoy_user.user_principal_name}@${data.azuread_domains.current.domains[0].domain_name}"
  display_name           = "${var.scenario4_entra_decoy_user.display_name}"
  password               = "${var.scenario4_entra_decoy_user.password}"
  force_password_change  = false
}

data "azuread_user" "scenario4_user" {
  user_principal_name = "${var.spn_users[0].username}@${data.azuread_domains.current.domains[0].domain_name}"
}

resource "azuread_directory_role" "groups_administrator" {
  display_name = "Groups Administrator"
}

resource "azuread_directory_role_assignment" "scenario4_user_groups_administrator" {
  role_id             = azuread_directory_role.groups_administrator.template_id
  principal_object_id = data.azuread_user.scenario4_user.object_id
}

resource "azuread_directory_role" "global_admin" {
  display_name = "Global Administrator"
}

resource "azuread_directory_role_assignment" "scenario4_decoy_user_global_admin" {
  role_id             = azuread_directory_role.global_admin.template_id
  principal_object_id = azuread_user.scenario4_decoy_user.object_id
}
