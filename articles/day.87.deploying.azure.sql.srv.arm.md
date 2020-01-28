# Day 87 - Deploying Azure SQL Server using ARM

Today we will cover how to deploy an Azure SQL Server in Azure and how to and how to import a Database using a BACPAC file.

</br>

> **NOTE:** This article was tested and written for a Linux Host running Ubuntu 18.04 with Azure CLI installed.

</br>

The steps for today's article are below.

[Deploy a new Resource Group](#deploy-a-new-resource-group)</br>
[Create the ARM Template File](#create-the-arm-template-file)</br>
[Deploy the ARM Template](#deploy-the-arm-template)</br>
[Retrieve the Credentials of the SQL Admin Account](#retrieve-the-credentials-of-the-sql-admin-account)</br>
[Create a Firewall Rule for your Public IP](#create-a-firewall-rule-for-your-public-ip)</br>
[Create a Storage Account to use to Import SQL Databases](#create-a-storage-account-to-use-to-import-sql-databases)</br>
[Upload a Database BACPAC File](#upload-a-database-bacpac-file)</br>
[Import the Database into the Azure SQL Server](#import-the-database-into-the-azure-sql-server)</br>
[Things to Consider](#things-to-consider)</br>
[Conclusion](#conclusion)</br>

## Deploy a new Resource Group

Using Azure CLI, run the following command to create a new Resource Group.

```bash
az group create \
--name 100days-azsql \
--location westeurope
```

You should get back the following output:

```json
{
  "id": "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/100days-azsql",
  "location": "westeurope",
  "managedBy": null,
  "name": "100days-azsql",
  "properties": {
    "provisioningState": "Succeeded"
  },
  "tags": null,
  "type": "Microsoft.Resources/resourceGroups"
}
```

</br>

## Create the ARM Template File

Below is the ARM Template File that we will be using to deploy the Azure SQL Server and a Database.

Copy the contents below into a file called **azuredeploy.json**.

```json
{
  "$schema": "https://schema.management.azure.com/schemas/2019-04-01/deploymentTemplate.json#",
  "contentVersion": "1.0.0.0",
  "parameters": {
      "skuName": {
      "type": "string",
      "defaultValue": "B1",
      "allowedValues": [
        "F1",
        "D1",
        "B1",
        "B2",
        "B3",
        "S1",
        "S2",
        "S3",
        "P1",
        "P2",
        "P3",
        "P4"
      ],
      "metadata": {
        "description": "Describes plan's pricing tier and instance size. Check details at https://azure.microsoft.com/en-us/pricing/details/app-service/"
      }
    },
    "skuCapacity": {
      "type": "int",
      "defaultValue": 1,
      "minValue": 1,
      "maxValue": 3,
      "metadata": {
        "description": "Describes plan's instance count"
      }
    },
    "sqlAdministratorLogin": {
      "type": "string",
      "defaultValue": "sqladmdays",
      "metadata": {
        "description": "The administrator username of the SQL Server."
      }
    },
    "sqlAdministratorLoginPassword": {
      "type": "securestring",
      "defaultValue": "[guid(resourceGroup().id, deployment().name)]",
      "metadata": {
        "description": "The administrator password of the SQL Server."
      }
    },
    "location": {
      "type": "string",
      "defaultValue": "[resourceGroup().location]",
      "metadata": {
        "description": "Location for all resources."
      }
    }
  },
  "variables": {
    "sqlServerName": "[concat('100dayssqlsrv-', substring(uniqueString(resourceGroup().id), 0, 3))]",
    "hostingPlanName": "[concat('sqlsite-hostingplan-', substring(uniqueString(resourceGroup().id),0, 3))]",
    "webSiteName": "[concat('sqlsite-', substring(uniqueString(resourceGroup().id),0, 3))]",
    "databaseName": "wide-world-imports-std",
    "databaseEdition": "Standard",
    "databaseCollation": "SQL_Latin1_General_CP1_CI_AS",
    "databaseServiceObjectiveName": "S2"
  },
  "resources": [
    {
      "name": "[variables('sqlServerName')]",
      "type": "Microsoft.Sql/servers",
      "apiVersion": "2014-04-01",
      "location": "[parameters('location')]",
      "tags": {
        "displayName": "SqlServer"
      },
      "properties": {
        "administratorLogin": "[parameters('sqlAdministratorLogin')]",
        "administratorLoginPassword": "[parameters('sqlAdministratorLoginPassword')]",
        "version": "12.0"
      },
      "resources": [
        {
          "name": "[variables('databaseName')]",
          "type": "databases",
          "apiVersion": "2015-01-01",
          "location": "[parameters('location')]",
          "tags": {
            "displayName": "Database"
          },
          "properties": {
            "edition": "[variables('databaseEdition')]",
            "collation": "[variables('databaseCollation')]",
            "requestedServiceObjectiveName": "[variables('databaseServiceObjectiveName')]"
          },
          "dependsOn": [
            "[variables('sqlServerName')]"
          ]
        },
        {
          "name": "AllowAllMicrosoftAzureIps",
          "type": "firewallrules",
          "apiVersion": "2014-04-01",
          "location": "[parameters('location')]",
          "properties": {
            "endIpAddress": "0.0.0.0",
            "startIpAddress": "0.0.0.0"
          },
          "dependsOn": [
            "[variables('sqlServerName')]"
          ]
        }
      ]
    },
{
      "apiVersion": "2018-02-01",
      "name": "[variables('hostingPlanName')]",
      "type": "Microsoft.Web/serverfarms",
      "location": "[parameters('location')]",
      "tags": {
        "displayName": "HostingPlan"
      },
      "sku": {
        "name": "[parameters('skuName')]",
        "capacity": "[parameters('skuCapacity')]"
      },
      "properties": {
        "name": "[variables('hostingPlanName')]"
      }
    },
    {
      "apiVersion": "2018-02-01",
      "name": "[variables('webSiteName')]",
      "type": "Microsoft.Web/sites",
      "location": "[parameters('location')]",
      "dependsOn": [
        "[variables('hostingPlanName')]"
      ],
      "tags": {
        "[concat('hidden-related:', resourceId('Microsoft.Web/serverfarms', variables('hostingPlanName')))]": "empty",
        "displayName": "Website"
      },
      "properties": {
        "name": "[variables('webSiteName')]",
        "serverFarmId": "[resourceId('Microsoft.Web/serverfarms', variables('hostingPlanName'))]"
      },
      "resources": [
        {
          "apiVersion": "2018-02-01",
          "type": "config",
          "name": "connectionstrings",
          "dependsOn": [
            "[variables('webSiteName')]"
          ],
          "properties": {
            "DefaultConnection": {
              "value": "[concat('Data Source=tcp:', reference(concat('Microsoft.Sql/servers/', variables('sqlserverName'))).fullyQualifiedDomainName, ',1433;Initial Catalog=', variables('databaseName'), ';User Id=', parameters('sqlAdministratorLogin'), '@', reference(concat('Microsoft.Sql/servers/', variables('sqlserverName'))).fullyQualifiedDomainName, ';Password=', parameters('sqlAdministratorLoginPassword'), ';')]",
              "type": "SQLAzure"
            }
          }
        }
      ]
    }
  ]
}
```

Below is a table of the Parameter Values that will be passed to the ARM Template at runtime.

|Name|Type|Default Value|Description|
|----|----|-----------|-----|
|skuName | String | B1 | Describes the Web App Hosting plan's pricing tier and instance size. |
|skuCapacity | Integer | 1 | The Number of instances to run. |
|sqlAdministratorLogin|String|sqladmdays|The administrator username of the SQL Server.|
|sqlAdministratorLoginPassword|secureString|[ARM Template guid Function](https://docs.microsoft.com/en-us/azure/azure-resource-manager/templates/template-functions-string#guid)|The administrator password of the SQL Server.|
|location|String|Resource Group Location|Azure Location to Use.|

</br>

## Deploy the ARM Template

Run the following command to deploy the ARM Template using the Azure CLI

```bash
az group deployment create \
--resource-group 100days-azsql \
--template-file azuredeploy.json \
--output table
```

The deployment should run for a few minutes and should output the following when it's completed.

```console
Name         ResourceGroup     State      Timestamp                         Mode
-----------  ----------------  ---------  --------------------------------  -----------
azuredeploy  100days-azsql     Succeeded  2020-01-20T15:20:53.896948+00:00  Incremental
```

</br>

## Retrieve the Credentials of the SQL Admin Account

In [Day 86](day.86.deploying.azure.sql.srv.azure.cli.md) we provided three options you could use to retrieve the SQL Admin User Password that was auto-generated. Those same basic options apply here as well. To make this quick, replace the three characters after **sqlsite-** in the *--name* switch below with whatever is currently in place for your Web App in the Azure Portal and then run the command.

```bash
az webapp config connection-string list \
--name sqlsite-dol \
--resource-group 100days-azsql \
--query [].value.value \
--output tsv
```

You should get back the connection string currently in use for the Web App to connect to the PostgreSQL Server.

```console
Data Source=tcp:100dayssqlsrv-dol.database.windows.net,1433;Initial Catalog=wide-world-imports-std;User Id=sqladmdays@100dayssqlsrv-dol.database.windows.net;Password=ff5b2522-ff34-5477-96d5-da2d182d46cb;
```

</br>

## Create a Firewall Rule for your Public IP

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
