# Day 95 - Deploying Azure DB for MariaDB in Azure using ARM

MariaDB is a community-developed, commercially supported fork of the MariaDB relational database management system (RDBMS), intended to remain free and open-source software under the GNU General Public License. Development is led by some of the original developers of MariaDB, who forked it due to concerns over its acquisition by Oracle. Microsoft some years ago hatched a new cloud-hosted model of MariaDB in Azure PaaS, with their **Azure Database for MariaDB** offering.

In this article:

[Service Features](#service-features) </br>
[Sample ARM Template](#sample-arm-template) </br>
[MariaDB Admin Tools](#mariadb-admin-tools) </br>

You can use the resources in this article with info available in previous installments in this series to deploy Azure Database for MariaDB from a release pipeline in Azure Pipelines.

***
SPONSOR: Need to stop and start your development VMs on a schedule? The Azure Resource Scheduler let's you schedule up to 10 Azure VMs for FREE! Learn more [HERE](https://azuremarketplace.microsoft.com/en-us/marketplace/apps/lumagatena.resourcescheduler?tab=Overview)
***

## Service Features

Azure DB for MariaDB shares a service model with Azure DB for MySQL and others, in that Microsoft manages the server instance, and much of the care and feeding for you. For example, OS and MariaDB patching are automatic. The service includes some monitoring capability, offering the ability to set alerts and act on the database thresholds. It includes a backup feature, allowing some control of retention (ranging from 7 - 35 days) and geo-redundancy of backup storage. Your newly deployed instance even includes a firewall for the service, blocking all connections by default.

> **NOTE**: You can modify the script in [Day 93](https://github.com/starkfell/100DaysOfIaC/blob/master/articles/day.93.postgres.ext.backups.md) to create a long-term retention strategy if 35 days is not enough.

There is a JSON reference for the service at [Microsoft.DBforMariaDB resource types](https://docs.microsoft.com/en-us/azure/templates/microsoft.dbforMariaDB/allversions) which will help you track down properties, and explanation of their allowed values.

## Sample ARM Template

This is a sample template I use in the lab, and is an enhanced version of an old Azure QuickStart template, which will deploy:

- Azure DB for MariaDB instance, with your choice of version 10.2 or 10.3.
- An empty database (matching your web app name)
- Firewall settings on the instance with a rule to allow all Azure IPs.
- Database backups (with 7 day retention and no geo-redundancy to save costs)
- An Azure app service instance with a connection string configured to the backend database

All things considered, it's a great way to get a look at Azure Database for MariaDB in a broader configuration that resembles something your developers might put together.

The full ARM template is shown below, as well as in the [day95](../resources/day95) folder in the resources in this Git repository.
``` JSON
{
    "$schema": "https://schema.management.azure.com/schemas/2019-04-01/deploymentTemplate.json#",
    "contentVersion": "1.0.0.0",
    "parameters": {
        "siteName": {
            "type": "string",
            "defaultValue": "100daysmariadb",
            "metadata": {
                "description": "Name of azure web app"
            }
        },
        "administratorLogin": {
            "type": "string",
            "defaultValue": "mydbadmin",
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
                "description": "Azure database for MariaDB compute capacity in vCores (2,4,8,16,32)"
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
                "description": "Azure database for MariaDB sku name "
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
                "description": "Azure database for MariaDB Sku Size "
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
                "description": "Azure database for MariaDB pricing tier"
            }
        },
        "MariaDBVersion": {
            "type": "string",
            "defaultValue": "10.3",
            "metadata": {
                "description": "MariaDB version"
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
                "description": "Azure database for MariaDB sku family"
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
                            "value": "[concat('Database=', variables('databaseName'), ';Data Source=', reference(resourceId('Microsoft.DBforMariaDB/servers',variables('serverName'))).fullyQualifiedDomainName, ';User Id=', parameters('administratorLogin'),'@', variables('serverName'),';Password=', parameters('administratorLoginPassword'))]",
                            "type": "Custom"
                        }
                    }
                }
            ]
        },
        {
            "apiVersion": "2018-06-01",
            "type": "Microsoft.DBforMariaDB/servers",
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
                "version": "[parameters('MariaDBVersion')]",
                "administratorLogin": "[parameters('administratorLogin')]",
                "administratorLoginPassword": "[parameters('administratorLoginPassword')]",
                "storageMB": "[parameters('databaseSkuSizeMB')]"
            },
            "resources": [
                {
                    "type": "firewallrules",
                    "apiVersion": "2018-06-01",
                    "dependsOn": [
                        "[concat('Microsoft.DBforMariaDB/servers/', variables('serverName'))]"
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
                    "apiVersion": "2018-06-01",
                    "properties": {
                        "charset": "utf8",
                        "collation": "utf8_general_ci"
                    },
                    "dependsOn": [
                        "[concat('Microsoft.DBforMariaDB/servers/', variables('serverName'))]"
                    ]
                }
            ]
        }
    ]
}
```

# MariaDB Admin Tools

My go-to admin tool for MariaDB is MySQL Workbench (remember MariaDB is a fork of MySQL), which you can download from the MySQL website at https://www.myqsl.com/products/workbench/.

## Conclusion

As you can see by now, the "Azure Database for..." family of PaaS database services makes moving your relational database workloads to the cloud easier than ever. And with comprehensive configuration available through ARM, it's easy to integrate into your Infrastructure-as-Code strategy in Azure DevOps.
