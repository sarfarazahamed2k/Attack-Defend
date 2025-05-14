#!/bin/bash

python3 -c '
import pandas as pd
df = pd.DataFrame()
df.to_excel("/workspace/files/Employee-Detail.xlsx", index=False)
'
cd terraform

echo "Please login with your Global Administrator account"
az login

SP_NAME="terraform_ansible_account"

echo "Creating service principal '$SP_NAME'..."
SP_OUTPUT=$(az ad sp create-for-rbac --name $SP_NAME)

APP_ID_AUTOMATION=$(echo $SP_OUTPUT | jq -r '.appId')
SP_PASSWORD=$(echo $SP_OUTPUT | jq -r '.password')
TENANT_ID=$(echo $SP_OUTPUT | jq -r '.tenant')

SP_OBJECT_ID=$(az ad sp list --display-name $SP_NAME --query '[0].id' --output tsv)

SUBSCRIPTION_ID=$(az account show --query id -o tsv)
echo "Using subscription ID: $SUBSCRIPTION_ID"
az account set --subscription $SUBSCRIPTION_ID

SCOPE="/subscriptions/$SUBSCRIPTION_ID"

echo "Generating SSH key pair..."
ssh-keygen -t rsa -b 4096 -f azure_key -N ""

echo "Appending SSH public key to terraform.tfvars..."
echo "ssh_public_key = \"$(cat azure_key.pub)\"" >> terraform.tfvars

echo "Assigning Owner role at subscription level..."
az role assignment create --assignee $SP_OBJECT_ID --role "Owner" --scope $SCOPE

echo "Assigning Monitoring Contributor role at subscription level..."
az role assignment create --assignee $SP_OBJECT_ID --role "Monitoring Contributor" --scope $SCOPE

echo "Assigning Key Vault Administrator role at subscription level..."
az role assignment create --assignee $SP_OBJECT_ID --role "Key Vault Administrator" --scope $SCOPE

echo "Assigning Security Administrator role..."
az rest --method POST --uri 'https://graph.microsoft.com/v1.0/roleManagement/directory/roleAssignments' \
                      --body "{'principalId': '$SP_OBJECT_ID', 'roleDefinitionId': '194ae4cb-b126-40b2-bd5b-6091b380977d', 'directoryScopeId': '/'}"

echo "Assigning User Administrator role..."
az rest --method POST --uri 'https://graph.microsoft.com/v1.0/roleManagement/directory/roleAssignments' \
                      --body "{'principalId': '$SP_OBJECT_ID', 'roleDefinitionId': 'fe930be7-5e62-47db-91af-98c3a49a38b1', 'directoryScopeId': '/'}"

echo "Assigning Privileged Role Administrator role..."
az rest --method POST --uri 'https://graph.microsoft.com/v1.0/roleManagement/directory/roleAssignments' \
                      --body "{'principalId': '$SP_OBJECT_ID', 'roleDefinitionId': 'e8611ab8-c189-46e8-94e1-60213ab1f814', 'directoryScopeId': '/'}"

echo "Assigning Application Administrator role..."
az rest --method POST --uri 'https://graph.microsoft.com/v1.0/roleManagement/directory/roleAssignments' \
                      --body "{'principalId': '$SP_OBJECT_ID', 'roleDefinitionId': '9b895d92-2cd3-44c7-9d02-a6ac2d5ea5c3', 'directoryScopeId': '/'}"

echo "Exporting credentials as environment variables..."
export ARM_CLIENT_ID=$APP_ID_AUTOMATION
export ARM_CLIENT_SECRET=$SP_PASSWORD
export ARM_SUBSCRIPTION_ID=$SUBSCRIPTION_ID
export ARM_TENANT_ID=$TENANT_ID

echo "Creating WazuhLogCollector service principal"
APP_ID=$(az ad app create --display-name "WazuhLogCollector" --sign-in-audience "AzureADMyOrg" --query appId -o tsv)

az ad app permission add --id "$APP_ID" --api "ca7f3f0b-7d91-482c-8e09-c5d840d0eac5" --api-permissions "e8f6e161-84d0-4cd7-9441-2d46ec9ec3d5=Role"

az ad app permission add --id "$APP_ID" --api "00000003-0000-0000-c000-000000000000" --api-permissions "e1fe6dd8-ba31-4d61-89e7-88639da4683d=Scope"

sleep 60

az ad app permission admin-consent --id $APP_ID

az login --service-principal \
  --username "$APP_ID_AUTOMATION" \
  --password "$SP_PASSWORD" \
  --tenant "$TENANT_ID"

az account set --subscription "$SUBSCRIPTION_ID"

echo "Setup complete! Credentials exported as environment variables"

echo "Initializing Terraform..."
terraform init

echo "Creating Terraform execution plan..."
terraform plan -out=on-premise_plan.txt -var="continue_execution=no"

echo "Applying Terraform configuration..."
terraform apply -auto-approve -var="continue_execution=no" on-premise_plan.txt

# elasticIPAddress=$(cat /workspace/ansible/inventory.ini | grep "elk ansible_host" | awk -F= '{print $2}')
# elasticPassword=$(cat /workspace/ansible/output_on-premise.log | grep "New value: " | awk -F "New value: " '{print $2}' | tr -d '"')
dc_ip=$(cat /workspace/ansible/inventory.ini | grep "csrp-dc" | awk '{print $2}' | cut -d'=' -f2)
workstation_ip=$(cat /workspace/ansible/inventory.ini | grep "workstation-1" | awk '{print $2}' | cut -d'=' -f2)
domainName=$(cat /workspace/terraform/terraform.tfvars | grep "netbios_name" | awk -F '"' '{print $2}')
adminUsername=$(cat /workspace/terraform/terraform.tfvars | grep "domain_admin" -m 1 | awk -F '"' '{print $2}')
adminPassword=$(cat /workspace/terraform/terraform.tfvars | grep "domain_admin_password" -m 1 | awk -F '"' '{print $2}')
entraIDDomain=$(terraform show | grep -m 1 "onmicrosoft" | awk -F'"' '{print $2}')
entraIDConnectUser=$(cat /workspace/terraform/terraform.tfvars | grep "microsoft_entra_connect" -A 4 | grep "user_principal_name" | awk -F '"' '{print $2}')
entraIDConnectPassword=$(cat /workspace/terraform/terraform.tfvars | grep "microsoft_entra_connect" -A 4 | grep "password" | awk -F '"' '{print $2}')
entraConnectUsername=$(cat /workspace/terraform/terraform.tfvars | grep "entra_connect_config" -A 4 | grep "username" | awk -F '"' '{print $2}')
entraConnectPassword=$(cat /workspace/terraform/terraform.tfvars | grep "entra_connect_config" -A 4 | grep "password" | awk -F '"' '{print $2}')
scenario1WorkstationUsername=$(cat /workspace/terraform/terraform.tfvars | grep "scenario1_users" -A 8 | grep "username" | awk -F '"' '{print $2}')
scenario1WorkstationPassword=$(cat /workspace/terraform/terraform.tfvars | grep "scenario1_users" -A 8 | grep "password" | awk -F '"' '{print $2}')
scenario1OnlineUsername=$(cat /workspace/terraform/terraform.tfvars | grep "scenario1_entra_user" -A 4 | grep "user_principal_name" | awk -F '"' '{print $2}')
scenario1OnlinePassword=$(cat /workspace/terraform/terraform.tfvars | grep "scenario1_entra_user" -A 4 | grep "password" | awk -F '"' '{print $2}')


echo "Here are the creds needed to setup Azure Entra Connect:"
echo "Domain Controller IP Address: $dc_ip"
echo "Domain Administrator for login to the DC:"
echo "Username: $adminUsername"
echo "Password: $adminPassword"
echo ""

echo "Microsoft Entra ID user:"
echo "Username: $entraIDConnectUser@$entraIDDomain"
echo "Password: $entraIDConnectPassword"
echo ""

echo "Doman Entra Connect Service Principal:"
echo "Username: $domainName\\$entraConnectUsername"
echo "Password: $entraConnectPassword"
echo ""

echo "Here are the creds to login using a Entra ID user on Google Chrome on workstation machine:"
echo "Workstation IP Address: $workstation_ip"
echo "Remote Desktop Login to workstation machine:"
echo "Username: $scenario1WorkstationUsername"
echo "Password: $scenario1WorkstationPassword"
echo ""

echo "Credentials to login on the browser: https://portal.azure.com"
echo "Username: $scenario1OnlineUsername@$entraIDDomain"
echo "Password: $scenario1OnlinePassword"
echo ""

# echo "Elastic Machine:"
# echo "IP addrress: $elasticIPAddress"
# echo "Kibana Endpoint: 127.0.0.1:5601"
# echo "Kibana Username: elastic"
# echo "Kibana Password: $elasticPassword"
# echo ""

while true; do
    read -p "Complete manual setup and then type 'yes' once done: " response
    if [ "$response" = "yes" ]; then
        sleep 60
        break
    else
        echo "Invalid input. You must type 'yes' to continue."
    fi
done

echo "Creating Terraform execution plan..."
terraform plan -out=cloud_plan.txt -var="continue_execution=yes"

echo "Applying Terraform configuration..."
terraform apply -auto-approve -var="continue_execution=yes" cloud_plan.txt

terraform show > output.txt

LOG_ANALYTICS_READER_ROLE="73c42c96-874c-492b-b04d-ab87d138a893"
SUBSCRIPTION_ID=$(az account show --query id -o tsv)

SP_ID=$(az ad sp show --id $APP_ID --query id -o tsv)

WORKSPACES=$(az monitor log-analytics workspace list --subscription "$SUBSCRIPTION_ID" --query "[].id" -o tsv)

for WORKSPACE_ID in $WORKSPACES; do
    echo "Assigning Log Analytics Reader role to $APP_NAME for workspace $WORKSPACE_ID..."
    az role assignment create --assignee "$SP_ID" --role "$LOG_ANALYTICS_READER_ROLE" --scope "$WORKSPACE_ID"
done

scriptSetupWazuh="/workspace/setup_scripts/Setup-Wazuh.sh"
scriptSetupWazuhAgent="/workspace/setup_scripts/Setup-WazuhAgent.ps1"
scriptSysmon="/workspace/setup_scripts/Setup-Sysmon.ps1"
CLIENT_ID=$(az ad app list --display-name "WazuhLogCollector" --query "[0].appId" -o tsv)
CLIENT_SECRET=$(az ad app credential reset --id "$CLIENT_ID" --append --years 1 --query password -o tsv)

entraIDRGName=$(cat /workspace/terraform/cloud/MicrosoftEntraConnect/resource-group.tf | grep "azurerm_resource_group" -A 1 | grep "name" | awk -F '"' '{print $2}')
hrDepartmentRGName=$(cat /workspace/terraform/cloud/Scenario-1/resource-group.tf | grep "azurerm_resource_group" -A 1 | grep "name" | awk -F '"' '{print $2}')
itKeyvaultRGName=$(cat /workspace/terraform/cloud/Scenario-2/resource-group.tf | grep "azurerm_resource_group" -A 1 | grep "name" | awk -F '"' '{print $2}')
webappRGName=$(cat /workspace/terraform/cloud/Scenario-4/resource-group.tf | grep "azurerm_resource_group" -A 1 | grep "name" | awk -F '"' '{print $2}')

entraIDWorkspaceName=$(cat /workspace/terraform/cloud/MicrosoftEntraConnect/log-analytics-workspace.tf | grep "azurerm_log_analytics_workspace" -A 1 | grep "name" | awk -F '"' '{print $2}')
hrDepartmentWorkspaceName=$(cat /workspace/terraform/cloud/Scenario-1/log-analytics-workspace.tf | grep "azurerm_log_analytics_workspace" -A 1 | grep "name" | awk -F '"' '{print $2}')
itKeyvaultWorkspaceName=$(cat /workspace/terraform/cloud/Scenario-2/log-analytics-workspace.tf | grep "azurerm_log_analytics_workspace" -A 1 | grep "name" | awk -F '"' '{print $2}')
webappWorkspaceName=$(cat /workspace/terraform/cloud/Scenario-4/log-analytics-workspace.tf | grep "azurerm_log_analytics_workspace" -A 1 | grep "name" | awk -F '"' '{print $2}')

WORKSPACE_ID_entraid=$(az monitor log-analytics workspace show --resource-group "$entraIDRGName" --workspace-name "$entraIDWorkspaceName" --query customerId -o tsv)
WORKSPACE_ID_hrdeparment=$(az monitor log-analytics workspace show --resource-group "$hrDepartmentRGName" --workspace-name "$hrDepartmentWorkspaceName" --query customerId -o tsv)
WORKSPACE_ID_itkeyvault=$(az monitor log-analytics workspace show --resource-group "$itKeyvaultRGName" --workspace-name "$itKeyvaultWorkspaceName" --query customerId -o tsv)
WORKSPACE_ID_webapp=$(az monitor log-analytics workspace show --resource-group "$webappRGName" --workspace-name "$webappWorkspaceName" --query customerId -o tsv)

sed -i "s/<SERVICE_PRINCIPAL_APPLICATION_ID>/$CLIENT_ID/g" $scriptSetupWazuh
sed -i "s/<CLIENT_SECRET_VALUE>/$CLIENT_SECRET/g" $scriptSetupWazuh

sed -i "s/<entraid-workspace>/$WORKSPACE_ID_entraid/g" $scriptSetupWazuh
sed -i "s/<HR-Department-workspace>/$WORKSPACE_ID_hrdeparment/g" $scriptSetupWazuh
sed -i "s/<IT-LogAnalytics-Workspace>/$WORKSPACE_ID_itkeyvault/g" $scriptSetupWazuh
sed -i "s/<WebApp-workspace>/$WORKSPACE_ID_webapp/g" $scriptSetupWazuh

resourceGroupName="on-premise"
wazuhVmName="Wazuh-VM"
winServerVmName="CSRP-DC"
win11VmName="workstation-1"

az vm run-command invoke --resource-group $resourceGroupName --name $wazuhVmName --command-id RunShellScript --scripts @$scriptSetupWazuh > /workspace/setup_scripts/output.txt

sed -i "s/$CLIENT_ID/<SERVICE_PRINCIPAL_APPLICATION_ID>/g" $scriptSetupWazuh
sed -i "s/$CLIENT_SECRET/<CLIENT_SECRET_VALUE>/g" $scriptSetupWazuh

sed -i "s/$WORKSPACE_ID_entraid/<entraid-workspace>/g" $scriptSetupWazuh
sed -i "s/$WORKSPACE_ID_hrdeparment/<HR-Department-workspace>/g" $scriptSetupWazuh
sed -i "s/$WORKSPACE_ID_itkeyvault/<IT-LogAnalytics-Workspace>/g" $scriptSetupWazuh
sed -i "s/$WORKSPACE_ID_webapp/<WebApp-workspace>/g" $scriptSetupWazuh

az vm run-command invoke --resource-group $resourceGroupName --name $winServerVmName --command-id RunPowerShellScript --scripts @$scriptSetupWazuhAgent

az vm run-command invoke --resource-group $resourceGroupName --name $win11VmName --command-id RunPowerShellScript --scripts @$scriptSetupWazuhAgent

az vm run-command invoke --resource-group $resourceGroupName --name $winServerVmName --command-id RunPowerShellScript --scripts @$scriptSysmon

az vm run-command invoke --resource-group $resourceGroupName --name $win11VmName --command-id RunPowerShellScript --scripts @$scriptSysmon

# attackVMResourceGroupName=$(cat /workspace/terraform/red/resource-group.tf | grep "name" | awk -F '"' '{print $2}')
# attackVMName=$(cat /workspace/terraform/red/compute.tf | grep "name" -m 1 | awk -F '"' '{print $2}')
# scriptFrontDoor="/workspace/setup_scripts/Setup-FrontDoor.sh"

# sed -i "s/resourceGroupName=/resourceGroupName=\"$attackVMResourceGroupName\"/" $scriptFrontDoor
# sed -i "s/vmName=/vmName=\"$attackVMName\"/" $scriptFrontDoor
# sed -i "s/endpointName=/endpointName=\"$attackVMResourceGroupName\"/" $scriptFrontDoor

# bash /workspace/setup_scripts/Setup-FrontDoor.sh

# $domainName\\
local_administrator=$(cat /workspace/terraform/terraform.tfvars | grep "admin_username" | awk -F '"' '{print $2}')
server_domain=$(cat /workspace/ansible/inventory_red.ini | grep "default_frontdoor_domain" | awk -F= '{print $2}')
server_ip=$(cat /workspace/ansible/inventory_red.ini | grep "attackvm" | awk -F= '{print $2}')
scenario1Username=$(cat /workspace/terraform/terraform.tfvars | grep "scenario1_users" -A 2 | grep "username" | awk -F '"' '{print $2}')
scenario1Password=$(cat /workspace/terraform/terraform.tfvars | grep "scenario1_users" -A 5 | grep "password" | awk -F '"' '{print $2}')
administrator_user=$(cat /workspace/terraform/terraform.tfvars | grep "domain_admin" -m 1 | awk -F '"' '{print $2}')
scenario1DecoyUsername=$(cat /workspace/terraform/terraform.tfvars | grep "scenario1" -m 1 -A 13 | tail -n 5 | grep "username" | awk -F '"' '{print $2}')
scenario1DecoyPassword=$(cat /workspace/terraform/terraform.tfvars | grep "scenario1" -m 1 -A 13 | tail -n 5 | grep "password" | awk -F '"' '{print $2}')
scenario1AzureUsername=$(cat /workspace/terraform/terraform.tfvars | grep "scenario1_entra_user" -A 4 | grep "user_principal_name" | awk -F '"' '{print $2}')
scenario1AzurePassword=$(cat /workspace/terraform/terraform.tfvars | grep "scenario1_entra_user" -A 4 | grep "password" | awk -F '"' '{print $2}')
scenario1StorageNameBeginning=$(cat /workspace/terraform/cloud/Scenario-1/blob-storage.tf | grep "azurerm_storage_account" -A 1 | grep "name" | awk -F '"' '{print $2}' | cut -d'$' -f1)
scenario1StorageName=$(az storage account list --query "[?starts_with(name, '$scenario1StorageNameBeginning')].name" -o tsv)
scenario1ContainerName=$(cat /workspace/terraform/cloud/Scenario-1/blob-storage.tf | grep "azurerm_storage_container" -A 1 | grep "name" | awk -F '"' '{print $2}')
scenario1Script="/workspace/ansible/tasks/attacker_setup/files/Scenario-1.sh"

sed -i "s/<local_administrator>/$local_administrator/g" $scenario1Script
sed -i "s/<server_ip>/$server_ip/g" $scenario1Script
sed -i "s/<server_domain>/$server_domain/g" $scenario1Script
sed -i "s/<workstation_ip>/$workstation_ip/g" $scenario1Script
sed -i "s/<entraIDDomain>/$entraIDDomain/g" $scenario1Script
sed -i "s/<scenario1Username>/$scenario1Username/g" $scenario1Script
sed -i "s/<scenario1Password>/$scenario1Password/g" $scenario1Script
sed -i "s/<administrator_user>/$administrator_user/g" $scenario1Script
sed -i "s/<scenario1DecoyUsername>/$scenario1DecoyUsername/g" $scenario1Script
sed -i "s/<scenario1DecoyPassword>/$scenario1DecoyPassword/g" $scenario1Script
sed -i "s/<scenario1AzureUsername>/$scenario1AzureUsername/g" $scenario1Script
sed -i "s/<scenario1AzurePassword>/$scenario1AzurePassword/g" $scenario1Script
sed -i "s/<scenario1StorageName>/$scenario1StorageName/g" $scenario1Script
sed -i "s/<scenario1ContainerName>/$scenario1ContainerName/g" $scenario1Script


domainControllerName=$domainName-DC
scenario2Username=$(cat /workspace/terraform/terraform.tfvars | grep "scenario2_users" -A 3 | grep "username" | awk -F '"' '{print $2}')
scenario2Password=$(cat /workspace/terraform/terraform.tfvars | grep "scenario2_users" -A 6 | grep "password" | awk -F '"' '{print $2}')
scenario2VaultNameBeginning=$(cat /workspace/terraform/cloud/Scenario-2/key-vault.tf | grep "azurerm_key_vault" -A 1 | grep "name" | awk -F '"' '{print $2}' | cut -d'$' -f1)
scenario2VaultName=$(az keyvault list --query "[].name" -o tsv | grep "$scenario2VaultNameBeginning")
scenario2OnPremiseUser=$(az keyvault secret list --vault-name $scenario2VaultName --query "[].name" -o tsv | grep -v "Admin")
scenario2AzureUsername=$(cat /workspace/terraform/terraform.tfvars | grep "scenario2_entra_user" -A 3 | grep "user_principal_name" | awk -F '"' '{print $2}')
scenario2AzurePassword=$(cat /workspace/terraform/terraform.tfvars | grep "scenario2_entra_user" -A 3 | grep "password" | awk -F '"' '{print $2}')
scenario2DecoyUser=$(az keyvault secret list --vault-name $scenario2VaultName --query "[].name" -o tsv | grep "Admin")
scenario2DecoyUsername=$(cat /workspace/terraform/terraform.tfvars | grep "scenario2_entra_decoy_user" -A 3 | grep "user_principal_name" | awk -F '"' '{print $2}')
scenario2DecoyPassword=$(cat /workspace/terraform/cloud/Scenario-2/key-vault-secrets.tf | grep "decoy_credential" -A 2 | grep "value" | cut -d':' -f2 | tr -d '"')
scenario2DecoyFile=$(cat /workspace/ansible/scenario_vars/scenario-2.yml | grep "filename" | cut -d':' -f2 | cut -d':' -f2 | tr -d '"' | tr -d ' ')
scenario2Script="/workspace/ansible/tasks/attacker_setup/files/Scenario-2.sh"

sed -i "s/<local_administrator>/$local_administrator/g" $scenario2Script
sed -i "s/<server_ip>/$server_ip/g" $scenario2Script
sed -i "s/<server_domain>/$server_domain/g" $scenario2Script
sed -i "s/<workstation_ip>/$workstation_ip/g" $scenario2Script
sed -i "s/<entraIDDomain>/$entraIDDomain/g" $scenario2Script
sed -i "s/<domainControllerName>/$domainControllerName/g" $scenario2Script
sed -i "s/<scenario2Username>/$scenario2Username/g" $scenario2Script
sed -i "s/<scenario2Password>/$scenario2Password/g" $scenario2Script
sed -i "s/<scenario2VaultName>/$scenario2VaultName/g" $scenario2Script
sed -i "s/<scenario2OnPremiseUser>/$scenario2OnPremiseUser/g" $scenario2Script
sed -i "s/<scenario2AzureUsername>/$scenario2AzureUsername/g" $scenario2Script
sed -i "s/<scenario2AzurePassword>/$scenario2AzurePassword/g" $scenario2Script
sed -i "s/<scenario2DecoyUser>/$scenario2DecoyUser/g" $scenario2Script
sed -i "s/<scenario2DecoyUsername>/$scenario2DecoyUsername/g" $scenario2Script
sed -i "s/<scenario2DecoyPassword>/$scenario2DecoyPassword/g" $scenario2Script
sed -i "s/<scenario2DecoyFile>/$scenario2DecoyFile/g" $scenario2Script


scenario3Username=$(cat /workspace/terraform/terraform.tfvars | grep "scenario3_users" -A 2 | grep "username" | awk -F '"' '{print $2}')
scenario3Password=$(cat /workspace/terraform/terraform.tfvars | grep "scenario3_users" -A 5 | grep "password" | awk -F '"' '{print $2}')
scenario3DecoyUsername=$(cat /workspace/terraform/terraform.tfvars | grep "scenario3_users" -A 13 | tail -n 4 | grep "username" | awk -F '"' '{print $2}')
scenario3DecoyPassword=$(cat /workspace/terraform/terraform.tfvars | grep "scenario3_users" -A 13 | tail -n 4 | grep "password" | awk -F '"' '{print $2}')
administrator_password=$(cat /workspace/terraform/terraform.tfvars | grep "domain_admin_password" | awk -F '"' '{print $2}')
scenario3ScheduledTask=$(cat /workspace/ansible/tasks/on-premise_setup/create_scheduled_task.yml | grep "name" -m 2 | tail -n 1 | cut -d':' -f2 | tr -d ' ')
scenario3VMName=$(cat /workspace/terraform/cloud/Scenario-4/compute.tf | grep "azurerm_linux_virtual_machine" -A 1 | grep "name" | awk -F '"' '{print $2}')
scenario3NSGName=$(cat /workspace/terraform/cloud/Scenario-4/security.tf  | grep "azurerm_network_security_group" -A 1 | grep "name" | awk -F '"' '{print $2}')
scenario3DecoyFile=$(cat /workspace/ansible/tasks/cloud_setup/copy_file.yml | grep "dest" | cut -d':' -f2 | tr -d '"' | tr -d ' ' | awk -F'/' '{print $NF}')
service_principal_name=$(cat /workspace/terraform/terraform.tfvars | grep "service_principal_name" | awk -F '"' '{print $2}')
scenario3Script="/workspace/ansible/tasks/attacker_setup/files/Scenario-3.sh"

sed -i "s/<local_administrator>/$local_administrator/g" $scenario3Script
sed -i "s/<server_ip>/$server_ip/g" $scenario3Script
sed -i "s/<server_domain>/$server_domain/g" $scenario3Script
sed -i "s/<workstation_ip>/$workstation_ip/g" $scenario3Script
sed -i "s/<entraIDDomain>/$entraIDDomain/g" $scenario3Script
sed -i "s/<scenario3Username>/$scenario3Username/g" $scenario3Script
sed -i "s/<scenario3Password>/$scenario3Password/g" $scenario3Script
sed -i "s/<scenario3DecoyUsername>/$scenario3DecoyUsername/g" $scenario3Script
sed -i "s/<scenario3DecoyPassword>/$scenario3DecoyPassword/g" $scenario3Script
sed -i "s/<administrator_user>/$administrator_user/g" $scenario3Script
sed -i "s/<administrator_password>/$administrator_password/g" $scenario3Script
sed -i "s/<entraIDRGName>/$entraIDRGName/g" $scenario3Script
sed -i "s/<hrDepartmentRGName>/$hrDepartmentRGName/g" $scenario3Script
sed -i "s/<itKeyvaultRGName>/$itKeyvaultRGName/g" $scenario3Script
sed -i "s/<webappRGName>/$webappRGName/g" $scenario3Script
sed -i "s/<scenario3ScheduledTask>/$scenario3ScheduledTask/g" $scenario3Script
sed -i "s/<scenario3VMName>/$scenario3VMName/g" $scenario3Script
sed -i "s/<scenario3NSGName>/$scenario3NSGName/g" $scenario3Script
sed -i "s/<scenario3DecoyFile>/$scenario3DecoyFile/g" $scenario3Script
sed -i "s/<service_principal_name>/$service_principal_name/g" $scenario3Script


scenario4Username=$(cat /workspace/terraform/terraform.tfvars | grep "scenario4_users" -A 2 | grep "username" | awk -F '"' '{print $2}')
scenario4Password=$(cat /workspace/terraform/terraform.tfvars | grep "scenario4_users" -A 5 | grep "password" | awk -F '"' '{print $2}')
scenario4ServiceUsername=$(cat /workspace/terraform/terraform.tfvars | grep "spn_user" -A 6 | grep "username" | awk -F '"' '{print $2}')
scenrio4ServicePassword=$(cat /workspace/terraform/terraform.tfvars | grep "spn_user" -A 6 | grep "password" | awk -F '"' '{print $2}')
scenario4ServiceSPN=$(cat /workspace/terraform/terraform.tfvars | grep "spn_user" -A 6 | grep "mssql_spn" | awk -F '"' '{print $2}')
scenario4DecoyFile=$(cat /workspace/ansible/scenario_vars/scenario-4.yml | grep "filename" | cut -d':' -f2 | cut -d':' -f2 | tr -d '"' | tr -d ' ')
scenario4VMName=$(cat /workspace/terraform/cloud/Scenario-4/compute.tf | grep "azurerm_linux_virtual_machine" -A 1 | grep "name" | awk -F '"' '{print $2}')
scenario4DecoyUsername=$(cat /workspace/terraform/terraform.tfvars | grep "scenario4_entra_decoy_user" -A 4 | grep "user_principal_name" | awk -F '"' '{print $2}')
scenario4DecoyPassword=$(cat /workspace/terraform/cloud/Scenario-4/compute.tf | grep "script" | cut -d':' -f2 | cut -d"'" -f1)
scenario4Script="/workspace/ansible/tasks/attacker_setup/files/Scenario-4.sh"

sed -i "s/<local_administrator>/$local_administrator/g" $scenario4Script
sed -i "s/<server_ip>/$server_ip/g" $scenario4Script
sed -i "s/<server_domain>/$server_domain/g" $scenario4Script
sed -i "s/<workstation_ip>/$workstation_ip/g" $scenario4Script
sed -i "s/<entraIDDomain>/$entraIDDomain/g" $scenario4Script
sed -i "s/<scenario4VMName>/$scenario4VMName/g" $scenario4Script
sed -i "s/<scenario4Username>/$scenario4Username/g" $scenario4Script
sed -i "s/<scenario4Password>/$scenario4Password/g" $scenario4Script
sed -i "s/<scenario4ServiceUsername>/$scenario4ServiceUsername/g" $scenario4Script
sed -i "s/<scenrio4ServicePassword>/$scenrio4ServicePassword/g" $scenario4Script
sed -i "s#<scenario4ServiceSPN>#$scenario4ServiceSPN#g" $scenario4Script
sed -i "s/<scenario4DecoyFile>/$scenario4DecoyFile/g" $scenario4Script
sed -i "s/<webappRGName>/$webappRGName/g" $scenario4Script
sed -i "s/<scenario4VMName>/$scenario4VMName/g" $scenario4Script
sed -i "s/<scenario4DecoyUsername>/$scenario4DecoyUsername/g" $scenario4Script
sed -i "s/<scenario4DecoyPassword>/$scenario4DecoyPassword/g" $scenario4Script

cd ../ansible
ansible-playbook -i inventory_red.ini playbook-configure-attackvm.yml

cd ../terraform

wazuhIP=$(terraform show | grep "wazuh_pip" -A 6 | grep "ip_address" | awk -F '"' '{print $2}')
wazuhPassword=$(cat /workspace/setup_scripts/output.txt | grep -o "Password: [^\\]*" | cut -d' ' -f2)
wazuhURL=$(cat /workspace/setup_scripts/output.txt | grep -oP '(?<=the web interface)[^\\n]*')

echo "Login as these users and set up MFA:"
echo "Username1: $scenario1AzureUsername@$entraIDDomain"
echo "Password1: $scenario1AzurePassword"
echo "Username2: $scenario2Username@$entraIDDomain"
echo "Password2: $scenario2Password"
echo "Username3: $scenario3Username@$entraIDDomain"
echo "Password3: $scenario3Password"
echo "Username4: $scenario4ServiceUsername@$entraIDDomain"
echo "Password4: $scenrio4ServicePassword"
echo ""

echo "Wazuh Portal Details:"
echo "Wazuh VM IP: $wazuhIP"
echo "URL: $wazuhURL"
echo "Username: admin"
echo "Password: $wazuhPassword"
echo ""

webAppIP=$(terraform show | grep "web_app_pip" -A 6 | grep "ip_address" | awk -F '"' '{print $2}')
echo "Web App VM IP: $webAppIP"
echo ""

attackVMIP=$(terraform show | grep "attack_vm_pip" -A 6 | grep "ip_address" | awk -F '"' '{print $2}')
echo "Attacker VM IP: $attackVMIP"

