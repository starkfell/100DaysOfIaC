# Day 86 - Deploying Azure SQL Server using the Azure CLI

Today we will cover how to deploy an Azure SQL Server in Azure and how to and how to import a Database using a BACPAC file.

</br>

The steps for today's article are below.

[Deploy a new Resource Group](#deploy-a-new-resource-group)</br>
[Generate a Password for the Azure SQL Server](#generate-a-password-for-the-azure-sql-server)</br>
[Generate a 4-character Alphanumeric Surname for the SQL Server](#generate-a-4-character-alphanumeric-surname-for-the-sql-server)</br>
[Deploy the Azure SQL Server and Blank Database](#deploy-the-azure-sql-server-and-blank-database)</br>
[Create a Storage Account to use to Import SQL Databases](#create-a-storage-account-to-use-to-import-sql-databases)</br>
[Upload a Database BACPAC File](#upload-a-database-bacpac-file)</br>
[Import the Database into the Azure SQL Server](#import-the-database-into-the-azure-sql-server)</br>
[Things to Consider](#things-to-consider)</br>
[Conclusion](#conclusion)</br>

## Deploy a new Resource Group

Using Azure CLI, run the following command to create a new Resource Group.

```bash
az group create \
--name 100days-azuredb \
--location westeurope
```

You should get back the following output:

```json
{
  "id": "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/100days-azuredb",
  "location": "westeurope",
  "managedBy": null,
  "name": "100days-azuredb",
  "properties": {
    "provisioningState": "Succeeded"
  },
  "tags": null,
  "type": "Microsoft.Resources/resourceGroups"
}
```

</br>

## Generate a Password for the Azure SQL Server

Run the following command to generate a Password for the Azure SQL Server Admin User.

```bash
SQL_SRV_ADMIN_PASSWORD=$(cat /proc/sys/kernel/random/uuid)
```

</br>

## Generate a 4-character Alphanumeric Surname for the SQL Server

Next, run the following command to generate a random 4-character set of alphanumeric characters.

```bash
RANDOM_ALPHA=$(cat /dev/urandom | tr -dc 'a-z0-9' | fold -w 4 | head -n 1)
```

</br>

If you are using a Mac, use the command below instead.

```bash
RANDOM_ALPHA=$(LC_CTYPE=C tr -dc 'a-z0-9' < /dev/urandom | fold -w 4 | head -n 1)
```

</br>

## Deploy the Azure SQL Server and Blank Database

Run the following command to deploy the Azure SQL Server.

```bash
az sql server create \
--name "100days-azuresqlsrv-$RANDOM_ALPHA" \
--resource-group "100days-azuredb" \
--location "westeurope" \
--admin-user "sqladmdays" \
--admin-password $SQL_SRV_ADMIN_PASSWORD \
--query '[name,state]' \
--output tsv
```

You should get back something similar to the response below.

```console
100days-azuresqlsrv-st4c
Ready
```

</br>

Next, run the following command to create a new Database on the SQL Server.

```bash
az sql db create \
--name "wide-world-imports-std" \
--resource-group "100days-azuredb" \
--server "100days-azuresqlsrv-$RANDOM_ALPHA" \
--edition Standard \
--family Gen5 \
--service-objective S2 \
--query '[name,status]' \
--output tsv
```

You should get back the following response when the database is finished deploying.

```console
wide-world-imports-std
Online
```

</br>

Run the following command to Allow Azure Services and resources to access the SQL Server.

```bash
az sql server firewall-rule create \
--name "allow-azure-services" \
--resource-group "100days-azuredb" \
--server "100days-azuresqlsrv-$RANDOM_ALPHA" \
--start-ip-address "0.0.0.0" \
--end-ip-address "0.0.0.0"
```

You should get back a response similar to the output below.

```console
{
  "endIpAddress": "0.0.0.0",
  "id": "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/100days-azuredb/providers/Microsoft.Sql/servers/100days-azuresqlsrv-st4c/firewallRules/allow-azure-services",
  "kind": "v12.0",
  "location": "West Europe",
  "name": "allow-azure-services",
  "resourceGroup": "100days-azuredb",
  "startIpAddress": "0.0.0.0",
  "type": "Microsoft.Sql/servers/firewallRules"
}
```

</br>

Next, run the following command to retrieve your Public IP Address.

```bash
MY_PUB_IP=$(dig +short myip.opendns.com @resolver1.opendns.com)
```

>NOTE: You can also use a third-party site or Google "what is my ip address" to retrieve your Public IP Address and set it to the **MY_PUB_IP** variable.

</br>

Run the following command to create a new Firewall Rule on the Azure SQL Server to grant yourself access.

```bash
az sql server firewall-rule create \
--name "my-public-ip" \
--resource-group "100days-azuredb" \
--server "100days-azuresqlsrv-$RANDOM_ALPHA" \
--start-ip-address $MY_PUB_IP \
--end-ip-address $MY_PUB_IP
```

You should get back a response similar to the output below.

```console
{
  "endIpAddress": "000.000.000.000",
  "id": "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/100days-azuredb/providers/Microsoft.Sql/servers/100days-azuresqlsrv-st4c/firewallRules/my-public-ip",
  "kind": "v12.0",
  "location": "West Europe",
  "name": "my-public-ip",
  "resourceGroup": "100days-azuredb",
  "startIpAddress": "000.000.000.000",
  "type": "Microsoft.Sql/servers/firewallRules"
}
```

>NOTE: Without this firewall rule, you won't be able to import the SQL Database later.

</br>

## Create a Storage Account to use to Import SQL Databases

Run the following command to create a new Storage Account

```bash
az storage account create \
--name "100daysqlimport$RANDOM_ALPHA" \
--resource-group "100days-azuredb" \
--location "westeurope" \
--query '[provisioningState,statusOfPrimary]' \
--output tsv
```

After the Storage Account has successfully provisioned, you should get back something similar to the response below.

```console
Succeeded
available
```

</br>

Next, run the following command to create a container for the SQL BACPAC file(s).

```bash
az storage container create \
--name "bacpac-files" \
--account-name "100daysqlimport$RANDOM_ALPHA"
```

You should get back the following response.

```json
{
  "created": true
}
```

</br>

Next, run the following command to retrieve the Storage Account Primary Key to use later.

```bash
AZ_STORAGE_PRIMARY_ACCOUNT_KEY=$(az storage account keys list \
--account-name "100daysqlimport$RANDOM_ALPHA" \
--query [0].value \
--output tsv)
```

</br>

## Upload a Database BACPAC File

Run the following command to download the **WideWorldImporters-Standard.bacpac** file from GitHub.

```bash
wget https://github.com/Microsoft/sql-server-samples/releases/download/wide-world-importers-v1.0/WideWorldImporters-Standard.bacpac
```

</br>

Next, run the following command to upload the **WideWorldImporters-Standard.bacpac** file to the Storage Account

```bash
az storage blob upload \
--name "WideWorldImporters-Standard.bacpac" \
--container-name "bacpac-files" \
--account-name "100daysqlimport$RANDOM_ALPHA" \
--file WideWorldImporters-Standard.bacpac
```

When the upload is finished, you should get back the following response.

```console
Finished[#############################################################]  100.0000%
{
  "etag": "\"0x8D7A2884878390D\"",
  "lastModified": "2020-01-26T17:50:51+00:00"
}
```

</br>

## Import the Database into the Azure SQL Server

```bash
az sql db import \
--name "wide-world-imports-std" \
--server "100days-azuresqlsrv-$RANDOM_ALPHA" \
--resource-group "100days-azuredb" \
--admin-user "sqladmdays" \
--admin-password $SQL_SRV_ADMIN_PASSWORD \
--storage-key-type "StorageAccessKey" \
--storage-key $AZ_STORAGE_PRIMARY_ACCOUNT_KEY \
--storage-uri "https://100daysqlimport$RANDOM_ALPHA.blob.core.windows.net/bacpac-files/WideWorldImporters-Standard.bacpac"

```

The Import process will take a few minutes to run. When it's completed you should get output similar to what is shown below.

```console
{
  "blobUri": "https://100daysqlimportst4c.blob.core.windows.net/bacpac-files/WideWorldImporters-Standard.bacpac",
  "databaseName": "wide-world-imports-std",
  "errorMessage": null,
  "id": "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/100days-azuredb/providers/Microsoft.Sql/servers/100days-azuresqlsrv-st4c/databases/wide-world-imports-std/extensions/import",
  "lastModifiedTime": "1/26/2020 9:50:51 PM",
  "name": "import",
  "queuedTime": "1/26/2020 9:36:48 PM",
  "requestId": "0f30e0e9-fcd9-4e02-b6fb-ad964e334050",
  "requestType": "Import",
  "resourceGroup": "100days-azuredb",
  "serverName": "100days-azuresqlsrv-st4c",
  "status": "Completed",
  "type": "Microsoft.Sql/servers/databases/extensions"
}
```

</br>

## Things to Consider

We recommend that you review how [Firewall Rules behave in Azure SQL Databases](https://docs.microsoft.com/en-us/azure/sql-database/sql-database-firewall-configure) and what to keep in mind when [importing BACPAC files to a database in Azure SQL Databases](https://docs.microsoft.com/en-us/azure/sql-database/sql-database-import?tabs=azure-powershell).

</br>

## Conclusion

In today's article we covered how to deploy an Azure SQL Server in Azure and how to and how to import a Database using a BACPAC file. If there's a specific scenario that you wish to be covered in future articles, please create a **[New Issue](https://github.com/starkfell/100DaysOfIaC/issues)** in the [starkfell/100DaysOfIaC](https://github.com/starkfell/100DaysOfIaC/) GitHub repository.
