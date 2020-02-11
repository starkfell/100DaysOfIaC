# Day 96 - Using Resource Locks on Individual Resources in Azure

In [Day 64](./articles.day.64.resource.locks.md), we covered how to implement Resource Locks in ARM Templates to prevent resources being removed at the Resource Group level. Today we are going to cover how to create Resource Locks for individual resources.

</br>

> **NOTE:** This article was tested and written for a Linux Host running Ubuntu 18.04 with Azure CLI installed.

</br>

In this article:

[Deploy Resources into Azure](#deploy-resources-into-azure) </br>
[Lock the Individual Resources](#lock-the-individual-resources) </br>
[Unlock the Individual Resources](#unlock-the-individual-resources) </br>
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

## Lock the Individual Resources

Instead of individually querying the **id** of each resource that we just deployed, we are going to query for all of the resources in the Resource Group at once and then return back the results in an array so it's easier to process them.

Run the following command to retrieve the **id** of all of the resources deployed in the **100days-reslocks** Resource Group.

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

## Unlock the Individual Resources

Run the following command to retrieve all of the lock IDs in the **100days-reslocks** Resource Group.

```bash
LOCK_IDS=$(az lock list \
--resource-group 100days-reslocks \
--query [].id \
--output tsv)
```

</br>

Run the following command to delete the locks in place for all of the Resources in the **100days-reslocks** Resource Group.

```bash
for ID in $LOCK_IDS;
do
    az lock delete \
    --id $ID \
    && echo "Deleted Resource Lock [$ID]"
done
```

You should get back the following response.

```console
Deleted Resource Lock [/subscriptions/84f065f5-e37a-4127-9c82-0b1ecd57a652/resourcegroups/100days-reslocks/providers/Microsoft.Storage/storageAccounts/iac100daysreslocksstr/providers/Microsoft.Authorization/locks/LockedResource]
Deleted Resource Lock [/subscriptions/84f065f5-e37a-4127-9c82-0b1ecd57a652/resourcegroups/100days-reslocks/providers/Microsoft.KeyVault/vaults/iac100daysreslockskv/providers/Microsoft.Authorization/locks/LockedResource]
Deleted Resource Lock [/subscriptions/84f065f5-e37a-4127-9c82-0b1ecd57a652/resourcegroups/100days-reslocks/providers/Microsoft.Network/virtualNetworks/100days-reslocks-vnet/providers/Microsoft.Authorization/locks/LockedResource]
```

> **NOTE** The **az lock delete** command doesn't return any readable output.

</br>

Run the following command to delete the **100days-reslocks** Resource Group.

```bash
az group delete \
--name "100days-reslocks" \
--yes
```

</br>

## Things to Consider

Even though the **az lock** commands are idempotent, be careful not to confuse updating the *notes* field with the *name* field. If you decide to use a different name for your Locks, remember to delete the old ones first, otherwise you'll have two different sets of locks in place.

</br>

## Conclusion

In today's article we covered how to implement Resource Locks for Azure Resources individually. In the next article, we'll be demonstrating how you can automate the management of Resource Locks on Individual Resources in Azure. If there's a specific scenario that you wish to be covered in future articles, please create a **[New Issue](https://github.com/starkfell/100DaysOfIaC/issues)** in the [starkfell/100DaysOfIaC](https://github.com/starkfell/100DaysOfIaC/) GitHub repository.
