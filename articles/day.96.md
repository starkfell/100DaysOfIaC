# Day 96 - Working with Resource Locking in Azure using the Azure CLI

In [Day](), we covered briefly resource locking at a Resource Group level. Today we are going to cover more about Resource Locking of individual resources.

In this article:

[Service Features](#service-features) </br>
[Sample ARM Template](#sample-arm-template) </br>
[MariaDB Admin Tools](#mariadb-admin-tools) </br>

## Deploy some Resources into Azure

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

## Lock the resources from Deletion

Instead of individually querying the **id** of each resource that we just deployed, we are going to query for all of the resources in the Resource Group at once.

Run the following command to retrieve the **id** of all of the resources deployed in the **100days-reslocks** Resource Group.

```bash
RESOURCE_IDS=$(az resource list --resource-group "100days-reslocks" --query [].id --output tsv)
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

Next, run the following command to create a **CanNotDelete** lock for each Resource.

```bash
for ID in $RESOURCE_IDS;
do
    az lock create \
    --name "LockedResource" \
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

> **NOTE:** You cannot delete the Resource Group while the resource locks are in place, even if you are the Owner of the Azure Subscription.

</br>

## Things to Consider

Azure Blueprints - https://docs.microsoft.com/en-us/azure/governance/blueprints/concepts/resource-locking