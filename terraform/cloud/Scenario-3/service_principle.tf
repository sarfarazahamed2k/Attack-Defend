data "azurerm_subscription" "current" {}

resource "azuread_application" "svc_web_backend" {
    display_name = "svc-web-backend"
}

resource "azuread_service_principal" "svc_web_backend" {
    client_id = azuread_application.svc_web_backend.client_id
}

resource "azurerm_role_assignment" "scenario3_user_access_administrator" {
    scope                = data.azurerm_subscription.current.id
    role_definition_name = "User Access Administrator"
    principal_id         = azuread_service_principal.svc_web_backend.object_id
    skip_service_principal_aad_check = true
}
