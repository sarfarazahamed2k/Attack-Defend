#!/bin/bash

sudo apt install -y fonts-liberation

curl https://packages.wazuh.com/4.9/wazuh-install.sh -o /tmp/wazuh-install.sh

curl https://packages.wazuh.com/4.9/config.yml -o /tmp/config.yml

sudo sed -i 's/<indexer-node-ip>/10.0.1.10/g' /tmp/config.yml

sudo sed -i 's/<wazuh-manager-ip>/10.0.1.10/g' /tmp/config.yml

sudo sed -i 's/<dashboard-node-ip>/10.0.1.10/g' /tmp/config.yml

sudo bash /tmp/wazuh-install.sh --generate-config-files

sudo bash /tmp/wazuh-install.sh --wazuh-indexer node-1

sudo bash /tmp/wazuh-install.sh --start-cluster

sudo bash /tmp/wazuh-install.sh --wazuh-server wazuh-1

sudo bash /tmp/wazuh-install.sh --wazuh-dashboard dashboard

rm -rf /tmp/wazuh-install.sh

mkdir /var/ossec/wodles/credentials

cat << 'EOF' >> /var/ossec/wodles/credentials/log_analytics_credentials
application_id = <SERVICE_PRINCIPAL_APPLICATION_ID>
application_key = <CLIENT_SECRET_VALUE>
EOF

cat << 'EOF' >> /var/ossec/etc/ossec.conf
<ossec_config>
<wodle name="azure-logs">
<disabled>no</disabled>
<run_on_start>yes</run_on_start>
<interval>5m</interval>
<log_analytics>
<auth_path>/var/ossec/wodles/credentials/log_analytics_credentials</auth_path>
<tenantdomain>sarfarazahamed2018gmail.onmicrosoft.com</tenantdomain>
<request>
<tag>AzureITCredStore</tag>
<query>AzureDiagnostics</query>
<workspace><IT-LogAnalytics-Workspace></workspace>
<time_offset>30m</time_offset>
</request>
<request>
<tag>AzureHRStorage</tag>
<query>StorageBlobLogs</query>
<workspace><HR-Department-workspace></workspace>
<time_offset>30m</time_offset>
</request>
<request>
<tag>AzureWebAppVMSyslog</tag>
<query>Syslog</query>
<workspace><WebApp-workspace></workspace>
<time_offset>30m</time_offset>
</request>
<request>
<tag>AzureWebAppVMPerf</tag>
<query>Perf</query>
<workspace><WebApp-workspace></workspace>
<time_offset>30m</time_offset>
</request>
<request>
<tag>AzureWebAppNSG</tag>
<query>AzureDiagnostics</query>
<workspace><WebApp-workspace></workspace>
<time_offset>30m</time_offset>
</request>
<request>
<tag>AzureEntraIDSignin</tag>
<query>SigninLogs</query>
<workspace><entraid-workspace></workspace>
<time_offset>30m</time_offset>
</request>
<request>
<tag>AzureEntraIDGraph</tag>
<query>MicrosoftGraphActivityLogs</query>
<workspace><entraid-workspace></workspace>
<time_offset>30m</time_offset>
</request>
<request>
<tag>AzureEntraIDAudit</tag>
<query>AuditLogs</query>
<workspace><entraid-workspace></workspace>
<time_offset>30m</time_offset>
</request>
<request>
<tag>AzureEntraIDServicePrincipal</tag>
<query>AADServicePrincipalSignInLogs</query>
<workspace><entraid-workspace></workspace>
<time_offset>30m</time_offset>
</request>
<request>
<tag>AzureEntraIDNonInteractiveUser</tag>
<query>AADNonInteractiveUserSignInLogs</query>
<workspace><entraid-workspace></workspace>
<time_offset>30m</time_offset>
</request>
<request>
<tag>AzureEntraIDManagedIdentity</tag>
<query>AADManagedIdentitySignInLogs</query>
<workspace><entraid-workspace></workspace>
<time_offset>30m</time_offset>
</request>
</log_analytics>
</wodle>
</ossec_config>
EOF


cat << 'EOF' > /var/ossec/etc/rules/local_rules.xml
<group name="azure,signin,">

  <rule id="100001" level="3">
    <if_sid>87801</if_sid>
    <field name="log_analytics_tag">AzureEntraIDNonInteractiveUser</field>
    <description>Azure: AADNonInteractiveUserSignInLogs</description>
    <options>no_full_log</options>
  </rule>

  <rule id="100002" level="3">
    <if_sid>87801</if_sid>
    <field name="log_analytics_tag">AzureEntraIDSignin</field>
    <description>Azure: SigninLogs</description>
    <options>no_full_log</options>
  </rule>

  <rule id="100003" level="3">
    <if_sid>87801</if_sid>
    <field name="log_analytics_tag">AzureEntraIDServicePrincipal</field>
    <description>Azure: AADServicePrincipalSignInLogs</description>
    <options>no_full_log</options>
  </rule>

  <rule id="100004" level="3">
    <if_sid>100001</if_sid>
    <field name="Identity" negate="yes">On-Premises Directory Synchronization Service Account</field>
    <description>Azure: AADNonInteractiveUserSignInLogs without Synchronisation</description>
    <options>no_full_log</options>
  </rule>

  <rule id="100005" level="3">
    <if_sid>100004</if_sid>
    <field name="AppDisplayName">Microsoft Azure CLI</field>
    <description>Azure: Microsoft Azure CLI in AADNonInteractiveUserSignInLogs</description>
    <options>no_full_log</options>
  </rule>

  <rule id="100006" level="16">
    <if_sid>100005</if_sid>
    <field name="Identity" negate="yes">Sarfaraz Ahamed</field>
    <field name="Identity" negate="yes">MSSQL Service Account</field>
    <description>Azure: User is not allowed to use CLI</description>
    <options>no_full_log</options>
  </rule>

  <rule id="100007" level="16">
    <if_sid>100001,100002</if_sid>
    <match>John Strand Admin|Corey Ham</match>
    <description>Azure: Honeyuser Triggered</description>
    <options>no_full_log</options>
  </rule>


<rule id="100008" level="3">
    <if_sid>100003</if_sid>
    <field name="ServicePrincipalName" negate="yes">WazuhLogCollector</field>
    <description>Azure: AADServicePrincipalSignInLogs without Log Collector</description>
    <options>no_full_log</options>
  </rule>

</group>

<group name="azure,hrstorage,">

  <rule id="100009" level="3">
    <if_sid>87801</if_sid>
    <field name="log_analytics_tag">AzureHRStorage</field>
    <description>Azure: StorageBlobLogs in HR-Department</description>
    <options>no_full_log</options>
  </rule>

</group>

<group name="azure,itcredstore,">

  <rule id="100010" level="3">
    <if_sid>87801</if_sid>
    <field name="log_analytics_tag">AzureITCredStore</field>
    <description>Azure: AzureDiagnostics in IT-KeyVault-Dev</description>
    <options>no_full_log</options>
  </rule>

</group>

<group name="win_evt_channel,windows,authentication_success,remote_logon">

  <rule id="100011" level="3">
    <if_sid>92652</if_sid>
    <description>Remote Login on $(agent.name) by $(win.eventdata.subjectDomainName)\$(win.eventdata.targetUserName)</description>
    <options>no_full_log</options>
  </rule>

  <rule id="100012" level="3">
    <if_sid>92657</if_sid>
    <description>Remote Login on $(agent.name) by $(win.eventdata.subjectDomainName)\$(win.eventdata.targetUserName)</description>
    <options>no_full_log</options>
  </rule>

</group>

<group name="sysmon,sysmon_eid11_detections,windows,psexec,">

  <rule id="100013" level="16">
    <if_sid>92217</if_sid>
    <field name="win.eventdata.targetFilename" type="pcre2">(?i).*psexesvc</field>
    <description>PsExec is detected on $(agent.name)</description>
    <options>no_full_log</options>
  </rule>

</group>

<group name="sysmon,sysmon_eid11_detections,windows,credentialkatz,">

  <rule id="100014" level="16">
    <if_sid>92205</if_sid>
    <field name="win.eventdata.targetFilename" type="pcre2">(?i).*credentialkatz</field>
    <description>CredentialKatz is detected on $(agent.name)</description>
    <options>no_full_log</options>
  </rule>

</group>


<group name="windows,windows_security,win_evt_channel,windows,authentication_success,decoyuser">

  <rule id="100015" level="16">
    <if_sid>60106</if_sid>
    <field name="win.eventdata.targetUserName">RalphMay</field>
    <description>RalphMay decoy user has been logged in</description>
    <options>no_full_log</options>
  </rule>

</group>


<group name="windows,windows_security,decoyuser">

  <rule id="100016" level="16">
    <if_sid>60104</if_sid>
    <field name="win.eventdata.targetUserName">SarfrazAhamedAdmin</field>
    <field name="win.system.eventID">4776</field>
    <description>SarfrazAhamedAdmin decoy user has tried to logged in</description>
    <options>no_full_log</options>
  </rule>

</group>



<group name="azure,syslog,">

  <rule id="100017" level="3">
    <if_sid>2501,87801</if_sid>
    <field name="log_analytics_tag">AzureWebAppVMSyslog</field>
    <description>Azure: Syslogs in WebApp</description>
    <options>no_full_log</options>
  </rule>

</group>

<group name="azure,perf,">

  <rule id="100018" level="3">
    <if_sid>87801</if_sid>
    <field name="log_analytics_tag">AzureWebAppVMPerf</field>
    <description>Azure: Perf in WebApp</description>
    <options>no_full_log</options>
  </rule>

</group>

<group name="azure,nsg,">

  <rule id="100019" level="3">
    <if_sid>87801</if_sid>
    <field name="log_analytics_tag">AzureWebAppNSG</field>
    <description>Azure: NSG in WebApp</description>
    <options>no_full_log</options>
  </rule>

</group>

<group name="azure,audit,">

  <rule id="100020" level="3">
    <if_sid>87801</if_sid>
    <field name="log_analytics_tag">AzureEntraIDAudit</field>
    <description>Azure: Audit Logs</description>
    <options>no_full_log</options>
  </rule>

</group>
EOF

systemctl restart wazuh-manager

