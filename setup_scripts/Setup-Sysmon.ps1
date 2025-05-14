# Define URLs and destination paths
$zipUrl = "https://download.sysinternals.com/files/Sysmon.zip"
$configUrl = "https://raw.githubusercontent.com/SwiftOnSecurity/sysmon-config/refs/heads/master/sysmonconfig-export.xml"
$zipDestination = "C:\Users\Public\Sysmon.zip"
$extractPath = "C:\Users\Public\Sysmon"
$configDestination = "$extractPath\sysmonconfig-export.xml"
$sysmonExePath = "$extractPath\sysmon.exe"

# Define the path to the ossec.conf file
$ossecConfPath = "C:\Program Files (x86)\ossec-agent\ossec.conf"

# Download the Sysmon.zip file
Invoke-WebRequest -Uri $zipUrl -OutFile $zipDestination

# Create the extraction directory if it doesn't exist
if (!(Test-Path -Path $extractPath)) {
    New-Item -ItemType Directory -Path $extractPath
}

# Extract the Sysmon.zip file
Add-Type -AssemblyName System.IO.Compression.FileSystem
[System.IO.Compression.ZipFile]::ExtractToDirectory($zipDestination, $extractPath)

# Download the Sysmon configuration file into the Sysmon folder
Invoke-WebRequest -Uri $configUrl -OutFile $configDestination

# Run sysmon.exe with the downloaded configuration file
if (Test-Path -Path $sysmonExePath) {
    & $sysmonExePath -accepteula -i $configDestination
    Write-Output "Sysmon has been installed and configured with sysmonconfig-export.xml."
} else {
    Write-Output "Sysmon executable not found in $extractPath."
}

Write-Output "Download, extraction, and configuration completed."

# Define the configuration to append
$sysmonConfig = @"
<ossec_config>
    <localfile>
        <location>Microsoft-Windows-Sysmon/Operational</location>
        <log_format>eventchannel</log_format>
    </localfile>
</ossec_config>
"@

# Check if ossec.conf file exists and append the configuration
if (Test-Path -Path $ossecConfPath) {
    Add-Content -Path $ossecConfPath -Value $sysmonConfig
    Write-Output "Sysmon configuration has been appended to ossec.conf."
} else {
    Write-Output "ossec.conf not found at $ossecConfPath."
}

Restart-Service -Name WazuhSvc

