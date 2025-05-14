output "primary_domain" {
  value = data.azuread_domains.current.domains[0].domain_name
}

output "entraid_workspace_name" {
  value = azurerm_log_analytics_workspace.workspace.name
}
