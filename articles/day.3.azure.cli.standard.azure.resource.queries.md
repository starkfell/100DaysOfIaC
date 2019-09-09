# Day 3 - Azure CLI - Standard Azure Resource Queries

In general, displaying resources in the Azure CLI can be quite difficult. In most cases where you quickly need to be able to look at a single resource, you are probably better off using the Azure Portal. However, if you looking up specifics of several resources at once, then this just may be what you've been looking for.

This is the first of a series of articles where we will provide examples of how to display the Resource Queries in Azure using the Azure CLI and [JMESPath](jmespath.org) syntax.

<br />

## JMESPath

Full documentation on JMESPath can be found **[here](jmespath.org)**. In particular, make sure to read the Tutorial, Examples, and Specification sections.

*Note: There are plenty of blogs that have done a great job going through the technical aspects of using JMESPath, our purpose here is to give you some working examples and then let you go down the route of learning the technical details if you so desire.*

<br />

## Figuring out what you want to Query

Run the following command to spew out all of your existing Azure Resources in JSON format into a text file.

```bash
az resource list > sandbox.json
```

When you open this file, you should see output similar to what is shown below.

```json
[
  {
    "id": "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/primary-stg/providers/Microsoft.Network/virtualNetworks/vnet-stg",
    "identity": null,
    "kind": null,
    "location": "westeurope",
    "managedBy": null,
    "name": "vnet-stg",
    "plan": null,
    "properties": null,
    "resourceGroup": "primary-stg",
    "sku": null,
    "tags": {
      "Environment": "Stage",
      "Service": "Primary",
      "System": "Shared",
      "Team": "Shared"
    },
    "type": "Microsoft.Network/virtualNetworks"
  },
  {
    "id": "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/primary-stg/providers/Microsoft.Storage/storageAccounts/dumpsterfire",
    "identity": null,
    "kind": "StorageV2",
    "location": "westeurope",
    "managedBy": null,
    "name": "dumpsterfire",
    "plan": null,
    "properties": null,
    "resourceGroup": "primary-stg",
    "sku": {
      "capacity": null,
      "family": null,
      "model": null,
      "name": "Standard_LRS",
      "size": null,
      "tier": "Standard"
    },
    "tags": {
      "createdBy": "rick.dalton@contoso.com"
    },
    "type": "Microsoft.Storage/storageAccounts"
  },
```

By having all of your resources in Azure dumped into JSON format into a file, you now have a quick way to search for identifiers and values that you may want to query and sort by.

All of the queries that are provided in this article use the *identifier* **type** as the primary qualifier for what to query by.

<br />

## Display all Storage Accounts in your Azure Subscription

Below is a sample command that will return all of your existing Storage Accounts in your Azure Subscription.

```bash
az resource list --query "[?contains(type, 'storageAccounts')].{Name: name, Type: type, Location: location}" --output table
```

```bash
Name                      Type                               Location
------------------------  ---------------------------------  -----------
dumpsterfire              Microsoft.Storage/storageAccounts  westeurope
acc7fd79f68b3459aa95eb29  Microsoft.Storage/storageAccounts  westeurope
wedidntstartthe           Microsoft.Storage/storageAccounts  westeurope
csb09b2dcf356b62x47utx68  Microsoft.Storage/storageAccounts  westeurope
cloudshell20190226        Microsoft.Storage/storageAccounts  eastus
```

### Query Breakdown

The JMESPath query used above is shown below.

```bash
--query "[?contains(type, 'storageAccounts')].{Name: name, Type: type, Location: location}"
```

This can be read outloud as: Return all results containing **('?contains')** the *identifer* **'type'** and matching the string **'storageAccounts'**. For all of the data that is found, sort the data in JSON **'.{Name: name, Type: type, Location: location}'** by Name, Type, and Location.

When the query is returned without table formatting, it looks like what is shown below. This is why the **--output table** is used from the **az resource list** command.

```bash
[
  {
    "Location": "westeurope",
    "Name": "dumpsterfire",
    "Type": "Microsoft.Storage/storageAccounts"
  },
  {
    "Location": "westeurope",
    "Name": "acc7fd79f68b3459aa95eb29",
    "Type": "Microsoft.Storage/storageAccounts"
  },
  {
    "Location": "westeurope",
    "Name": "wedidntstartthe",
    "Type": "Microsoft.Storage/storageAccounts"
  },
  {
    "Location": "westeurope",
    "Name": "csb09b2dcf356b62x47utx68",
    "Type": "Microsoft.Storage/storageAccounts"
  },
  {
    "Location": "eastus",
    "Name": "cloudshell20190226",
    "Type": "Microsoft.Storage/storageAccounts"
  }
]
```

<br />

## More Examples

You can copy and paste the following samples below into the Azure CLI and your results will be returned in a clean and readable table format.

<br />

### Display all Virtual Networks in your Azure Subscription

```bash
az resource list \
--query "[?contains(type, 'virtualNetworks')].{Name: name, Type: type, Location: location}" \
--output table
```

<br />

### Display all Web Sites in your Azure Subscription

```bash
az resource list \
--query "[?contains(type, 'sites')].{Name: name, Type: type, Location: location}" \
--output table
```

<br />

### Display all Network Security Groups in your Azure Subscription

```bash
az resource list \
--query "[?contains(type, 'networkSecurityGroups')].{Name: name, Type: type, Location: location}" \
--output table
```

<br />

### Display all Alert Rules in your Azure Subscription

```bash
az resource list \
--query "[?contains(type, 'alertrules')].{Name: name, Type: type, Location: location}" \
--output table
```
