#!/bin/bash

cd terraform

echo "Destroying Terraform configuration..."
RETRY_DELAY=10
DELAY=2

while [ -n "$(terraform state list)" ]; do
  terraform destroy -var="continue_execution=no" -auto-approve
  sleep $RETRY_DELAY
done

echo "Infrastrcture has been destroyed"

echo "Destroying NetworkWatcher..."
LOCATION=$(grep '^location' /workspace/terraform/terraform.tfvars | cut -d'=' -f2 | tr -d '"')

az network watcher configure --resource-group NetworkWatcherRG --locations "$LOCATION" --enabled false
az group delete --name NetworkWatcherRG --yes

echo "NetworkWatcher has been destroyed"

SP_NAME="terraform_ansible_account"

APP_ID=$(az ad sp list --display-name $SP_NAME --query "[0].appId" -o tsv)

echo "Please login with your Global Administrator account"
az login

echo "Deleting service principal '$SP_NAME'..."
az ad sp delete --id $APP_ID

echo "Service principal '$SP_NAME' has been deleted"

echo "Deleting on-premise users..."
users=$(az ad user list --query "[].userPrincipalName" --output tsv)

while IFS= read -r user; do
  [ -n "$user" ] && az ad user delete --id "$user" && sleep $DELAY
done <<< "$users"

echo "On-premise users deleted"

cd ..
