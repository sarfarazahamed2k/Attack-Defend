#!/bin/bash

# Register the Microsoft.Cdn provider
az provider register --namespace Microsoft.Cdn

# Allow preview extensions for dynamic installation
az config set extension.dynamic_install=yes_without_prompt

# Ensure the front-door extension is installed and up to date
az extension add --name front-door --upgrade

# Define main variables
resourceGroupName=
profiles_service_name="service"
vmName=
endpointName=

# Fetch the IP address of the Kali VM to use as the origin hostname
kaliIpAddress=$(az vm list-ip-addresses --resource-group $resourceGroupName --name $vmName --query "[].virtualMachine.network.publicIpAddresses[0].ipAddress" -o tsv)

# Check if the IP address was successfully fetched
if [ -z "$kaliIpAddress" ]; then
  echo "Failed to retrieve the IP address for the VM $vmName in resource group $resourceGroupName"
  exit 1
fi

# Create the CDN profile without specifying `location` and `kind` to avoid issues
az cdn profile create \
  --name "$profiles_service_name" \
  --resource-group "$resourceGroupName" \
  --sku Standard_AzureFrontDoor

# Create the AFD endpoint within the CDN profile
az afd endpoint create \
  --profile-name "$profiles_service_name" \
  --resource-group "$resourceGroupName" \
  --name "$endpointName" \
  --enabled-state Enabled

privateLinkServiceId=$(az afd endpoint show \
  --name "$endpointName" \
  --profile-name "$profiles_service_name" \
  --resource-group "$resourceGroupName" \
  --query "id" -o tsv)

hostname=$(az afd endpoint show \
  --resource-group "$resourceGroupName" \
  --profile-name "$profiles_service_name" \
  --endpoint-name "$endpointName" \
  --query "hostName" -o tsv)


# Create the origin group with load-balancing and health probe settings
az afd origin-group create \
  --profile-name "$profiles_service_name" \
  --resource-group "$resourceGroupName" \
  --origin-group-name "default-origin-group" \
  --probe-path "/" \
  --probe-request-type HEAD \
  --probe-protocol Http \
  --probe-interval 100 \
  --sample-size 4 \
  --successful-samples-required 3 \
  --additional-latency-in-milliseconds 50 \
  --session-affinity-state "Disabled"

# Add the origin to the origin group using the fetched IP address
az afd origin create \
    --resource-group "$resourceGroupName" \
    --host-name "$hostname" \
    --profile-name "$profiles_service_name" \
    --origin-group-name "default-origin-group" \
    --origin-name "default-origin" \
    --origin-host-header "$hostname" \
    --priority 1 \
    --weight 1000 \
    --enabled-state Enabled \
    --http-port 80 \
    --https-port 443

# Create the route on the endpoint
az afd route create \
  --profile-name "$profiles_service_name" \
  --resource-group "$resourceGroupName" \
  --endpoint-name "$endpointName" \
  --route-name "default-route" \
  --origin-group "default-origin-group" \
  --patterns-to-match "/*" \
  --forwarding-protocol MatchRequest \
  --https-redirect Disabled \
  --link-to-default-domain Enabled \
  --supported-protocols Http \
  --enabled-state Enabled

echo "Deployment completed successfully!"
