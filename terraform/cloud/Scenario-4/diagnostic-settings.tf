resource "azurerm_monitor_diagnostic_setting" "nsg_diagnostic_settings" {
    name               = "nsg-setting"
    target_resource_id = azurerm_network_security_group.linux_nsg.id
    log_analytics_workspace_id = azurerm_log_analytics_workspace.workspace.id

    enabled_log {
        category = "NetworkSecurityGroupEvent"
    }

    enabled_log {
        category = "NetworkSecurityGroupRuleCounter"
    }
}
