resource "azurerm_virtual_machine_run_command" "setup_audit" {
    name                = "setup-audit"
    virtual_machine_id  = azurerm_linux_virtual_machine.web_app_vm.id
    location            = azurerm_linux_virtual_machine.web_app_vm.location

    source {
        script = <<EOF
#!/bin/bash
# Install and configure auditd
sudo apt install -y auditd
sudo auditctl -a always,exit -F arch=b64 -S execve -F dir=/bin -k commands
sudo auditctl -a always,exit -F arch=b64 -S execve -F dir=/usr/bin -k commands
sudo systemctl start auditd
sudo systemctl enable auditd

# Configure rsyslog for audit logs
sudo bash -c 'cat > /etc/rsyslog.d/10-auditd.conf << "RSYSLOG"
$ModLoad imfile
$InputFileName /var/log/audit/audit.log
$InputFileTag auditd:
$InputFileStateFile stat-audit
$InputFileSeverity info
$InputFileFacility local0
$InputRunFileMonitor
RSYSLOG'

# Restart rsyslog to apply changes
sudo systemctl restart rsyslog
EOF
    }

    depends_on = [
        azurerm_linux_virtual_machine.web_app_vm
    ]
}

resource "azurerm_monitor_data_collection_rule" "web_app_dcr" {
    name                = "UbuntuVM-DCR"
    resource_group_name = azurerm_resource_group.rg.name
    location            = azurerm_resource_group.rg.location
    kind                = "Linux"

    destinations {
        log_analytics {
            workspace_resource_id = azurerm_log_analytics_workspace.workspace.id
            name                  = "la-401337388"
        }
    }

    data_flow {
        destinations    = ["la-401337388"]
        output_stream    = "Microsoft-Perf"
        streams         = ["Microsoft-Perf"]
        transform_kql    = "source"
    }

    data_flow {
        destinations    = ["la-401337388"]
        output_stream    = "Microsoft-Syslog"
        streams         = ["Microsoft-Syslog"]
        transform_kql    = "source"
    }

    data_sources {
        syslog {
            facility_names = ["alert", "audit", "auth", "authpriv", "clock", "cron", "daemon", "ftp", "kern", "local0", "local1", "local2", "local3", "local4", "local5", "local6", "local7", "lpr", "mail", "news", "nopri", "ntp", "syslog", "user", "uucp"]
            log_levels     = ["Debug", "Info", "Notice", "Warning", "Error", "Critical", "Alert", "Emergency"]
            name           = "sysLogsDataSource-1688419672"
            streams      = ["Microsoft-Syslog"]
        }

        performance_counter {
            streams                       = ["Microsoft-Perf"]
            sampling_frequency_in_seconds = 60
            counter_specifiers            = [
                "Processor(*)\\% Processor Time",
                "Processor(*)\\% Idle Time",
                "Processor(*)\\% User Time",
                "Processor(*)\\% Nice Time",
                "Processor(*)\\% Privileged Time",
                "Processor(*)\\% IO Wait Time",
                "Processor(*)\\% Interrupt Time",
                "Memory(*)\\Available MBytes Memory",
                "Memory(*)\\% Available Memory",
                "Memory(*)\\Used Memory MBytes",
                "Memory(*)\\% Used Memory",
                "Memory(*)\\Pages/sec",
                "Memory(*)\\Page Reads/sec",
                "Memory(*)\\Page Writes/sec",
                "Memory(*)\\Available MBytes Swap",
                "Memory(*)\\% Available Swap Space",
                "Memory(*)\\Used MBytes Swap Space",
                "Memory(*)\\% Used Swap Space",
                "Process(*)\\Pct User Time",
                "Process(*)\\Pct Privileged Time",
                "Process(*)\\Used Memory",
                "Process(*)\\Virtual Shared Memory",
                "Logical Disk(*)\\% Free Inodes",
                "Logical Disk(*)\\% Used Inodes",
                "Logical Disk(*)\\Free Megabytes",
                "Logical Disk(*)\\% Free Space",
                "Logical Disk(*)\\% Used Space",
                "Logical Disk(*)\\Logical Disk Bytes/sec",
                "Logical Disk(*)\\Disk Read Bytes/sec",
                "Logical Disk(*)\\Disk Write Bytes/sec",
                "Logical Disk(*)\\Disk Transfers/sec",
                "Logical Disk(*)\\Disk Reads/sec",
                "Logical Disk(*)\\Disk Writes/sec",
                "Network(*)\\Total Bytes Transmitted",
                "Network(*)\\Total Bytes Received",
                "Network(*)\\Total Bytes",
                "Network(*)\\Total Packets Transmitted",
                "Network(*)\\Total Packets Received",
                "Network(*)\\Total Rx Errors",
                "Network(*)\\Total Tx Errors",
                "Network(*)\\Total Collisions",
                "System(*)\\Uptime",
                "System(*)\\Load1",
                "System(*)\\Load5",
                "System(*)\\Load15",
                "System(*)\\Users",
                "System(*)\\Unique Users",
                "System(*)\\CPUs"
            ]
            name                          = "perfCounterDataSource60"
        }
    }

    depends_on = [
        azurerm_virtual_machine_run_command.setup_audit
    ]
}

resource "azurerm_monitor_data_collection_rule_association" "web_app_dcr_association" {
    name                    = "UbuntuVM-DCR-Association"
    target_resource_id      = azurerm_linux_virtual_machine.web_app_vm.id
    data_collection_rule_id = azurerm_monitor_data_collection_rule.web_app_dcr.id
    depends_on = [
        azurerm_monitor_data_collection_rule.web_app_dcr
    ]
}

resource "azurerm_virtual_machine_extension" "ama_linux" {
    name                       = "AzureMonitorLinuxAgent"
    virtual_machine_id         = azurerm_linux_virtual_machine.web_app_vm.id
    publisher                  = "Microsoft.Azure.Monitor"
    type                       = "AzureMonitorLinuxAgent"
    type_handler_version       = "1.0"
    auto_upgrade_minor_version = true
    automatic_upgrade_enabled  = true

    settings = <<SETTINGS
    {
    "authentication": {
    "managedIdentity": {
    "identifier-name": "mi_res_id",
    "identifier-value": "${azurerm_linux_virtual_machine.web_app_vm.identity[0].principal_id}"
    }
    }
    }
    SETTINGS

    depends_on = [
        azurerm_monitor_data_collection_rule_association.web_app_dcr_association
    ]
}

