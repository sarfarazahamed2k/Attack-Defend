resource "azurerm_monitor_diagnostic_setting" "storage_account_diagnostic_settings" {
    name               = "hr-storage-account-setting"
    target_resource_id = azurerm_storage_account.hr_storage.id
    log_analytics_workspace_id = azurerm_log_analytics_workspace.workspace.id

    metric {
        category = "Transaction"
    }
}

resource "azurerm_monitor_diagnostic_setting" "container_diagnostic_settings" {
    name               = "hr-container-setting"
    target_resource_id = "${azurerm_storage_account.hr_storage.id}/blobServices/default"
    log_analytics_workspace_id = azurerm_log_analytics_workspace.workspace.id

    enabled_log {
        category = "StorageRead"
    }

    enabled_log {
        category = "StorageWrite"
    }

    enabled_log {
        category = "StorageDelete"
    }

    metric {
        category = "Transaction"
    }
}

