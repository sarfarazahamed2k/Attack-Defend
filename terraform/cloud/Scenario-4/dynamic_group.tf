data "azuread_user" "owner" {
    user_principal_name = "${var.spn_users[0].username}@${data.azuread_domains.current.domains[0].domain_name}"
}

resource "azuread_group" "web_app_developer" {
  display_name     = "Web App Developer"
  owners           = [data.azuread_user.owner.object_id]
  security_enabled = true
  types            = ["DynamicMembership"]

  dynamic_membership {
    enabled = true
    rule    = "(user.department -eq \"Developer\")"
  }
}


resource "azurerm_role_assignment" "web_app_group_vm_contributor" {
    scope                = azurerm_linux_virtual_machine.web_app_vm.id
    role_definition_name = "Contributor"
    principal_id         = azuread_group.web_app_developer.object_id
}
