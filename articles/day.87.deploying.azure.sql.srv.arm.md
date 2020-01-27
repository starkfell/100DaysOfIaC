# Day 86 - Deploying Azure SQL Server using ARM

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
|sqlAdministratorLogin|String|sqladmdays|The administrator username of the SQL Server|
|sqlAdministratorLoginPassword|secureString|[ARM Template guid Function](https://docs.microsoft.com/en-us/azure/azure-resource-manager/templates/template-functions-string#guid)|The administrator password of the SQL Server|
|location|String|Resource Group Location|Azure Location to Use|

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

## Things to Consider

We recommend that you review how [Firewall Rules behave in Azure SQL Databases](https://docs.microsoft.com/en-us/azure/sql-database/sql-database-firewall-configure) and what to keep in mind when [importing BACPAC files to a database in Azure SQL Databases](https://docs.microsoft.com/en-us/azure/sql-database/sql-database-import?tabs=azure-powershell).

</br>

## Conclusion

In today's article we covered how to deploy an Azure SQL Server in Azure and how to and how to import a Database using a BACPAC file. If there's a specific scenario that you wish to be covered in future articles, please create a **[New Issue](https://github.com/starkfell/100DaysOfIaC/issues)** in the [starkfell/100DaysOfIaC](https://github.com/starkfell/100DaysOfIaC/) GitHub repository.
