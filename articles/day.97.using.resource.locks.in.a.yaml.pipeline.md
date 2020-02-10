# Day 97 - Automating Resource Locks on Individual Resources in Azure

In [Day 96](./articles.day.96.resource.locks.md), we covered how to implement Resource Locks on individual resources in Azure. Today we are going to show you how you can automate the process of managing Azure Resources that have Resource Locks.

</br>

> **NOTE:** This article was tested and written for a Linux Host running Ubuntu 18.04 with Azure CLI installed.

</br>

In this article:

[Deploy Resources into Azure](#deploy-resources-into-azure) </br>
[Things to Consider](#things-to-consider)</br>
[Conclusion](#conclusion) </br>

## Deploy Resources into Azure

Run the following command to deploy the **100days-reslocks** Resource Group.

```bash
az group create \
--name 100days-reslocks \
--location westeurope
```

You should get back the following output:

```json
{
  "id": "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/100days-reslocks",
  "location": "westeurope",
  "managedBy": null,
  "name": "100days-reslocks",
  "properties": {
    "provisioningState": "Succeeded"
  },
  "tags": null,
  "type": "Microsoft.Resources/resourceGroups"
}
```

</br>

Next, run the following command to create a new VNet in the Resource Group.

```bash
az network vnet create \
--name "100days-reslocks-vnet" \
--resource-group "100days-reslocks" \
--address-prefix "172.16.0.0/16" \
--subnet-name "100days-reslocks-subnet" \
--subnet-prefix "172.16.1.0/24" \
--query "newVNet.provisioningState" \
--output tsv
```

You should get back a similar response.

```console
"Succeeded"
```

Next, run the following command to create a new Azure Key Vault in the Resource Group.

```bash
az keyvault create \
--name "iac100daysreslockskv" \
--resource-group "100days-reslocks" \
--output table
```

You should get back a similar response.

```console
Location    Name                   ResourceGroup
----------  --------------------   ----------------
westeurope  iac100daysreslockskv   100days-reslocks
```

Next, run the following command to create a new Azure Storage Account in the Resource Group.

```bash
/usr/bin/az storage account create \
--name "iac100daysreslocksstr" \
--resource-group "100days-reslocks" \
--sku Standard_LRS \
--query statusOfPrimary \
--output tsv
```

You should get back a similar response.

```console
available
```

</br>

## Lock the Azure Resources

Run the following command to retrieve the **ids** of all of the resources deployed in the **100days-reslocks** Resource Group.

```bash
RESOURCE_IDS=$(az resource list \
--resource-group "100days-reslocks" \
--query [].id \
--output tsv)
```

Run the following command to list the **ids** of the Resources.

```bash
echo "$RESOURCE_IDS"
```

You should get back a similar response.

```console
/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/100days-reslocks/providers/Microsoft.KeyVault/vaults/iac100daysreslockskv
/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/100days-reslocks/providers/Microsoft.Network/virtualNetworks/100days-reslocks-vnet
/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/100days-reslocks/providers/Microsoft.Storage/storageAccounts/iac100daysreslocksstr
```

</br>

Next, run the following command to create a **CanNotDelete** lock for each Resource.

```bash
for ID in $RESOURCE_IDS;
do
    az lock create \
    --name "LockedResources" \
    --notes "100DaysOfIac" \
    --lock-type CanNotDelete \
    --resource $ID \
    --query "id" \
    --output tsv
done
```

You should get back a similar response.

```console
/subscriptions/00000000-0000-0000-0000-000000000000/resourcegroups/100days-reslocks/providers/Microsoft.KeyVault/vaults/iac100daysreslockskv/providers/Microsoft.Authorization/locks/LockedResource
/subscriptions/00000000-0000-0000-0000-000000000000/resourcegroups/100days-reslocks/providers/Microsoft.Network/virtualNetworks/100days-reslocks-vnet/providers/Microsoft.Authorization/locks/LockedResource
/subscriptions/00000000-0000-0000-0000-000000000000/resourcegroups/100days-reslocks/providers/Microsoft.Storage/storageAccounts/iac100daysreslocksstr/providers/Microsoft.Authorization/locks/LockedResource
```

</br>

> **NOTE:** You will receive an error if you attempt to delete the Resource Group while the resource locks are in place.

</br>

## Tag the Resources

Tagging your Azure Resources is probably one of the easiest ways to not only keep track of them in Azure, but also to keep track what type of state they should be in. This could be anything from always being on to retired to permanent removal. The range of states you want to track your resources by is entirely up to you.

Next, we are going to Tag all of the Resources in the Resource Group.

```bash
for ID in $RESOURCE_IDS;
do
    az resource tag \
    --tags "Permanent=True" \
    --ids $ID \
    --query 'id' \
    --output tsv
done
```

You should get back a similar response.

```console
/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/100days-reslocks/providers/Microsoft.KeyVault/vaults/iac100daysreslockskv
/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/100days-reslocks/providers/Microsoft.Network/virtualNetworks/100days-reslocks-vnet
/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/100days-reslocks/providers/Microsoft.Storage/storageAccounts/iac100daysreslocksstr
```

</br>

## Update the Tag on the Storage Account

```bash
STORAGE_ID=$(az resource list \
--resource-group "100days-reslocks" \
| jq '.[].id | select(.|test("iac100daysreslocksstr"))' | tr -d '"')
```

```bash
az resource tag \
--tags "Permanent=False" \
--ids $STORAGE_ID \
--query 'id' \
--output tsv
```

```console
/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/100days-reslocks/providers/Microsoft.Storage/storageAccounts/iac100daysreslocksstr
```

</br>

## Delete a Locked Resource Based on a Tag

```bash
for ID in $RESOURCE_IDS;
do
    # Retrieving the Resource 'Permanent' Tag.
    CHECK_TAG=$(az resource show \
    --ids $ID \
    --query "tags.Permanent" \
    --output tsv)

    if [[ "$CHECK_TAG" == "True" ]]; then
        echo "[---info------] Not Marked for Removal, skipping."
    else
        echo "[---info------] [$ID] is marked for removal."

        # Removing the Lock on the Resource.
        REMOVE_LOCK=$(az lock delete \
        --name "LockedResources" \
        --resource $ID)

        if [ $? -eq 0 ]; then
            echo "[---success---] Removed Resource Lock on [$ID]."
        else
            echo "[---fail------] Failed to remove Resource Lock on [$ID]."
            echo "[---fail------] $REMOVE_LOCK"
        fi

        # Deleting the Resource.
        DELETE_RESOURCE=$(az resource delete --ids $ID)

        if [ $? -eq 0 ]; then
            echo "[---success---] Deleted Resource [$ID]."
        else
            echo "[---fail------] Failed to delete Resource[$ID]."
            echo "[---fail------] $DELETE_RESOURCE"
        fi
    fi
done
```


## Things to Consider

Ensuring that the script above will work for almost all resources in Azure will take some testing.

</br>

## Azure Build Pipeline

Follow the instructions in [Day 35](./day.35.building.a.practical.yaml.pipeline.part.1.md) for creating a Service Principal for the Build Pipeline and adding creating the Service Connection for it in Azure DevOps if you haven't already created the **sp-az-build-pipeline** Service Principal.

Next, in VS Code, replace the current contents of the **lock-pipe.yaml** file with what is shown below. Afterwards, save and commit your changes to the repository.

```yaml
# Builds are automatically triggered from the master branch in the 'practical-yaml-build-pipe' Repo.
trigger:
- master

pool:
  # Using a Microsoft Hosted Agent - https://docs.microsoft.com/en-us/azure/devops/pipelines/agents/hosted?view=azure-devops
  vmImage: ubuntu-18.04

steps:

# Azure CLI Task - Unlock Azure Resources.
- task: AzureCLI@2
  displayName: 'Unlock Azure Resources'
  inputs:
    # Using Service Principal, 'sp-az-build-pipeline', to authenticate to the Azure Subscription.
    azureSubscription: 'sp-az-build-pipeline'
    scriptType: 'bash'
    scriptLocation: 'scriptPath'
    scriptPath: './unlock-azure-resources.sh'

# Azure CLI Task - Delete Azure Resources with Tag 'SetForRemoval'.
- task: AzureCLI@2
  displayName: 'Build and Push NGINX Docker Image to ACR'
  inputs:
    # Using Service Principal, 'sp-az-build-pipeline', to authenticate to the Azure Subscription.
    azureSubscription: 'sp-az-build-pipeline'
    scriptType: 'bash'
    scriptLocation: 'scriptPath'
    scriptPath: './delete-azure-resources.sh'

# Azure CLI Task - Relock Azure Resources.
- task: AzureCLI@2
  displayName: 'Relock Azure Resources'
  inputs:
    # Using Service Principal, 'sp-az-build-pipeline', to authenticate to the Azure Subscription.
    azureSubscription: 'sp-az-build-pipeline'
    scriptType: 'bash'
    scriptLocation: 'scriptPath'
    scriptPath: './relock-azure-resourcese.sh'
```
