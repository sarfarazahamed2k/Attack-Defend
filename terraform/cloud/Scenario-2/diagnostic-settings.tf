resource "azurerm_monitor_diagnostic_setting" "key_vault_diagnostic_settings" {
    name               = "it-dev-key-vault-setting"
    target_resource_id = azurerm_key_vault.kv.id
    log_analytics_workspace_id = azurerm_log_analytics_workspace.workspace.id

    enabled_log {
        category = "AuditEvent"
    }

    enabled_log {
        category = "AzurePolicyEvaluationDetails"
    }

    metric {
        category = "AllMetrics"
    }
}

