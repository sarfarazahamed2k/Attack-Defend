data "azuread_domains" "current" {}

resource "azuread_directory_role" "app_admin" {
    display_name = "Application Administrator"
}

data "azuread_user" "targer_user" {
    user_principal_name = "${var.scenario3_users[0].username}@${data.azuread_domains.current.domains[0].domain_name}"
}

resource "azuread_directory_role_assignment" "app_admin_assignment" {
    role_id             = azuread_directory_role.app_admin.template_id
    principal_object_id = data.azuread_user.targer_user.object_id
}
