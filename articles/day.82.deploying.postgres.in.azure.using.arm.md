# Day 82 - Deploying PostgreSQL in Azure using ARM

Today we will cover how to deploy a PostgreSQL Server in Azure using ARM and how to connect it to a newly deployed Web Application.

</br>

In today's article we will cover the following scenarios when troubleshooting your Kubernetes Applications using **kubectl**.

[Deploy a new Resource Group](#deploy-a-new-resource-group)</br>
[Create the ARM Template File](#create-the-arm-template-file)</br>
[Retrieving the IP Address of a Pod](#retrieving-the-ip-address-of-a-pod)</br>
[Connecting to a Pod](#connecting-to-a-pod)</br>
[Things to Consider](#things-to-consider)</br>
[Conclusion](#conclusion)</br>

## Deploy a new Resource Group

Using Azure CLI, run the following command to create a new Resource Group.

```bash
az group create \
--name 100days-postgres \
--location westeurope
```

You should get back the following output:

```json
{
  "id": "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/100days-postgres",
  "location": "westeurope",
  "managedBy": null,
  "name": "100days-postgres",
  "properties": {
    "provisioningState": "Succeeded"
  },
  "tags": null,
  "type": "Microsoft.Resources/resourceGroups"
}
```

## Create the ARM Template File

Below is the ARM Template File that we will be using to deploy the PostgreSQL Server, a database, and an Azure Web App that will automatically be connected to the database.

Copy the contents below into a file called **azuredeploy.json**.

```json

```

</br>

Below is a table of the Parameter Values that will be passed to the ARM Template at runtime.

|Name|Type|Default Value|Description|
|----|----|-----------|-----|
|siteName|String|100dayspostgre|Name of the Azure Web App|
|administratorLogin|String|pgadmin|PostgreSQL Server Admin Login User|
|administratorLoginPassword|secureString|[ARM Template guid Function](https://docs.microsoft.com/en-us/azure/azure-resource-manager/templates/template-functions-string#guid)|PostgreSQL Server Admin Login Password|
|databaseSkuCapacity|Integer|2|Number of vCores to assign to the PostgreSQL Server|
|databaseSkuName|String|GP_Gen5_2|PostgreSQL Server SKU to use|
|databaseSkuSizeMB|Integer|51200|PostgreSQL Server Database Size in MB|
|databaseSkuTier|String|GeneralPurpose|PostgreSQL Server SKU Pricing Tier|
|postgresqlVersion|String|11|PostgreSQL Server Version|
|location|String|Resource Group Location|Azure Location to Use|

</br>

## Deploy the ARM Template

Run the following command to deploy the ARM Template using the Azure CLI

```bash
az group deployment create \
--resource-group 100days-postgres \
--template-file azuredeploy.json \
--output table
```

The deployment should run for a few minutes and should output the following when it's completed.

```console
Name         ResourceGroup     State      Timestamp                         Mode
-----------  ----------------  ---------  --------------------------------  -----------
azuredeploy  100days-postgres  Succeeded  2020-01-20T15:20:53.896948+00:00  Incremental
```

</br>

If you would like to retrieve the PostgreSQL Server Database Administrator Password that is generated with the [ARM Template guid Function](https://docs.microsoft.com/en-us/azure/azure-resource-manager/templates/template-functions-string#guid), you have some options.

</br>

Option 1: Add [output to the ARM Template](https://github.com/starkfell/100DaysOfIaC/blob/master/articles/day.67.outputs.md) to display the Password.

</br>

Option 2: In the Azure Portal, retrieve the Password from the **defaultConnection** String in the **Application Settings** of the Web Application.

</br>

Option 3: Run the following command below from the Azure CLI.

```bash
az webapp config connection-string list \
--name 100dayspostgre \
--resource-group 100days-postgres \
--query [].value.value \
--output tsv
```

You should get back the connection string currently in use for the Web App to connect to the PostgreSQL Server.

```console
Database=primary_100dayspostgredb;Server=100dayspostgresrv.postgres.database.azure.com;User Id=pgadmin@100dayspostgresrv;Password=602f2e38-3d43-547e-87e4-274cca70db33
```

</br>

## Things to Consider

The PostgreSQL Database name must be 63 or fewer characters and must start with a letter or an underscore. The rest of the string can contain letters, digits, and underscores.

If you need to deploy a PostgreSQL Server to a VNet, you need to use General Purpose or Performance. Basic doesn't support custom VNet Integration.

Specifying a Minor Version of PostgreSQL will cause your deployment to fail.

## Conclusion

In today's article we we covered several scenarios for using **kubectl** to assist in troubleshooting your Kubernetes Applications. If there's a specific scenario that you wish to be covered in future articles, please create a **[New Issue](https://github.com/starkfell/100DaysOfIaC/issues)** in the [starkfell/100DaysOfIaC](https://github.com/starkfell/100DaysOfIaC/) GitHub repository.
