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
{
    "$schema": "https://schema.management.azure.com/schemas/2015-01-01/deploymentTemplate.json#",
    "contentVersion": "1.0.0.0",
    "parameters": {
        "siteName": {
            "type": "string",
            "defaultValue": "100dayspostgre",
            "metadata": {
                "description": "Name of azure web app"
            }
        },
        "administratorLogin": {
            "type": "string",
            "defaultValue": "pgadmin",
            "minLength": 1,
            "metadata": {
                "description": "Database administrator login name"
            }
        },
        "administratorLoginPassword": {
            "type": "securestring",
            "defaultValue": "[guid(resourceGroup().id, deployment().name)]",
            "minLength": 8,
            "maxLength": 128,
            "metadata": {
                "description": "Database administrator password"
            }
        },
        "databaseSkuCapacity": {
            "type": "int",
            "defaultValue": 2,
            "allowedValues": [
                2,
                4,
                8,
                16,
                32
            ],
            "metadata": {
                "description": "Azure database for PostgreSQL compute capacity in vCores (2,4,8,16,32)"
            }
        },
        "databaseSkuName": {
            "type": "string",
            "defaultValue": "GP_Gen5_2",
            "allowedValues": [
                "GP_Gen5_2",
                "GP_Gen5_4",
                "GP_Gen5_8",
                "GP_Gen5_16",
                "GP_Gen5_32",
                "MO_Gen5_2",
                "MO_Gen5_4",
                "MO_Gen5_8",
                "MO_Gen5_16",
                "MO_Gen5_32",
                "B_Gen5_1",
                "B_Gen5_2"
            ],
            "metadata": {
                "description": "Azure database for PostgreSQL sku name "
            }
        },
        "databaseSkuSizeMB": {
            "type": "int",
            "defaultValue": 51200,
            "allowedValues": [
                102400,
                51200
            ],
            "metadata": {
                "description": "Azure database for PostgreSQL Sku Size "
            }
        },
        "databaseSkuTier": {
            "type": "string",
            "defaultValue": "GeneralPurpose",
            "allowedValues": [
                "GeneralPurpose",
                "MemoryOptimized",
                "Basic"
            ],
            "metadata": {
                "description": "Azure database for PostgreSQL pricing tier"
            }
        },
        "postgresqlVersion": {
            "type": "string",
            "defaultValue": "11",
            "metadata": {
                "description": "PostgreSQL version"
            }
        },
        "location": {
            "type": "string",
            "defaultValue": "[resourceGroup().location]",
            "metadata": {
                "description": "Location for all resources."
            }
        },
        "databaseskuFamily": {
            "type": "string",
            "defaultValue": "Gen5",
            "metadata": {
                "description": "Azure database for PostgreSQL sku family"
            }
        }
    },
    "variables": {
        "databaseName": "[concat('primary_', parameters('siteName'), 'db')]",
        "serverName": "[concat(parameters('siteName'), 'srv')]",
        "hostingPlanName": "[concat(parameters('siteName'), 'serviceplan')]"
    },
    "resources": [
        {
            "apiVersion": "2018-02-01",
            "name": "[variables('hostingPlanName')]",
            "type": "Microsoft.Web/serverfarms",
            "location": "[parameters('location')]",
            "properties": {
                "name": "[variables('hostingPlanName')]",
                "workerSize": "1",
                "numberOfWorkers": 0
            },
            "sku": {
                "Tier": "Standard",
                "Name": "S1"
            }
        },
        {
            "apiVersion": "2018-02-01",
            "name": "[parameters('siteName')]",
            "type": "Microsoft.Web/sites",
            "location": "[parameters('location')]",
            "dependsOn": [
                "[concat('Microsoft.Web/serverfarms/', variables('hostingPlanName'))]"
            ],
            "properties": {
                "name": "[parameters('siteName')]",
                "serverFarmId": "[variables('hostingPlanName')]"
                },
            "resources": [
                {
                    "apiVersion": "2018-02-01",
                    "name": "connectionstrings",
                    "type": "config",
                    "dependsOn": [
                        "[concat('Microsoft.Web/sites/', parameters('siteName'))]"
                    ],
                    "properties": {
                        "defaultConnection": {
                            "value": "[concat('Database=', variables('databaseName'), ';Server=', reference(resourceId('Microsoft.DBforPostgreSQL/servers',variables('serverName'))).fullyQualifiedDomainName, ';User Id=', parameters('administratorLogin'),'@', variables('serverName'),';Password=', parameters('administratorLoginPassword'))]",
                            "type": "PostgreSQL"
                        }
                    }
                }
            ]
        },
        {
            "apiVersion": "2017-12-01",
            "type": "Microsoft.DBforPostgreSQL/servers",
            "location": "[parameters('location')]",
            "name": "[variables('serverName')]",
            "sku": {
                "name": "[parameters('databaseSkuName')]",
                "tier": "[parameters('databaseSkuTier')]",
                "capacity": "[parameters('databaseSkucapacity')]",
                "size": "[parameters('databaseSkuSizeMB')]",
                "family": "[parameters('databaseskuFamily')]"
            },
            "properties": {
                "version": "[parameters('postgresqlVersion')]",
                "administratorLogin": "[parameters('administratorLogin')]",
                "administratorLoginPassword": "[parameters('administratorLoginPassword')]",
                "storageMB": "[parameters('databaseSkuSizeMB')]"
            },
            "resources": [
                {
                    "type": "firewallrules",
                    "apiVersion": "2017-12-01",
                    "dependsOn": [
                        "[concat('Microsoft.DBforPostgreSQL/servers/', variables('serverName'))]"
                    ],
                    "location": "[parameters('location')]",
                    "name": "[concat(variables('serverName'),'firewall')]",
                    "properties": {
                        "startIpAddress": "0.0.0.0",
                        "endIpAddress": "255.255.255.255"
                    }
                },
                {
                    "name": "[variables('databaseName')]",
                    "type": "databases",
                    "apiVersion": "2017-12-01",
                    "properties": {
                        "charset": "utf8",
                        "collation": "English_United States.1252"
                    },
                    "dependsOn": [
                        "[concat('Microsoft.DBforPostgreSQL/servers/', variables('serverName'))]"
                    ]
                }
            ]
        }
    ]
}
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

If you need to use virtual network rules for your PostgreSQL Server, you need to use General Purpose or Memory Optimized servers. Virtual network rules are not available to Basic servers.

</br>

## Conclusion

In today's article we we covered several scenarios for using **kubectl** to assist in troubleshooting your Kubernetes Applications. If there's a specific scenario that you wish to be covered in future articles, please create a **[New Issue](https://github.com/starkfell/100DaysOfIaC/issues)** in the [starkfell/100DaysOfIaC](https://github.com/starkfell/100DaysOfIaC/) GitHub repository.
