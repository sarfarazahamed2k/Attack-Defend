data "azuread_domains" "current" {}

resource "azuread_user" "microsoft_entra_connect" {
  user_principal_name    = "${var.microsoft_entra_connect.user_principal_name}@${data.azuread_domains.current.domains[0].domain_name}"
  display_name           = "${var.microsoft_entra_connect.display_name}"
  password               = "${var.microsoft_entra_connect.password}"
  force_password_change  = false
}

resource "azuread_directory_role" "hybrid_identity_administrator" {
  display_name = "Hybrid Identity Administrator"
}

resource "azuread_directory_role_assignment" "microsoft_entra_connect_hybrid_identity_administrator" {
  role_id             = azuread_directory_role.hybrid_identity_administrator.template_id
  principal_object_id = azuread_user.microsoft_entra_connect.object_id
}
