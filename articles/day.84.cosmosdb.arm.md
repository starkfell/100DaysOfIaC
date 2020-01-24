# Day 84 - Deploying Cosmos DB (with Mongo API) in Azure using ARM

In [Day 46](https://github.com/starkfell/100DaysOfIaC/blob/master/articles/day.46.cosmosdb.mongo.api.cli.md), we covered "**A Pipeline-friendly Script for Cosmos DB with Mongo API**", based on Azure CLI, which works very well in a release pipeline in our experience. However, Azure Resource Manager (ARM) templates are the standard for declarative, idempotent deployment of Cosmos DB with the Mongo API, so we thought a look at the ARM template route is warranted. This gives you options to choose for whatever needs may arise.

Azure Cosmos DB implements wire protocols of common NoSQL databases like Cassandra, Gremlin, Azure Tables Storage, and MongoDB.  By providing a native implementation of the wire protocols directly inside Cosmos DB, it allows the existing client SDKs, drivers, and tools of the NoSQL databases to interact with Cosmos DB just as though it were a MongoDB instance.

Last year, ARM template capabilities for Cosmos DB provisioning received a substantial update, allowing for creating containers, databases, graphs, namespaces and tables. Before that update, it was only possible through PowerShell, the portal, Mongo DB command line tools, or code. If memory serves, the Azure CLI capabilities with Cosmos DB were a step ahead of ARM when I was working with it in 2019.

In this article:

[Version Support](#version-support)</br>
[Sample ARM Template](#sample-arm-template)</br> 
[MongoDB Admin Tools](#mongodb-admin-tools)</br>
[Conclusion](#conclusion)</br>

## Version Support

Version support for new accounts created using Azure Cosmos DB's API for MongoDB are compatible with version 3.6 of the MongoDB wire protocol. MongoDBs latest release is 4.2, so if you're using features in MongoDB specific to 4.2, a switch to Cosmos DB with the Mongo API will not be possible.

## Sample ARM Template

Below is a sample ARM template to deploy Cosmos DB with MongoDB API. As you look through the template, you can find guidance on the meanings and allowed values for many of the template components [HERE](https://docs.microsoft.com/en-us/rest/api/cosmos-db-resource-provider/databaseaccounts/get)

> **NOTES:** My template includes default values for **primary and secondary regions** for the new Cosmos account, so be sure to adjust the defaults for what suits you, or remove them from the template. It also includes a couple of parameters for collection names. If you're new to Cosmos DB, create a couple of default **collections** just so you can see the result through one of the MongoDB admin tools mentioned later in this article. Naturally, you can cut these from the template pretty easily if you prefer.

```json
{
	"$schema": "https://schema.management.azure.com/schemas/2019-04-01/deploymentTemplate.json#",
	"contentVersion": "1.0.0.0",
	"parameters": {
		"accountName": {
			"type": "string",
			"defaultValue": "[concat('mongo-', uniqueString(resourceGroup().id))]",
			"metadata": {
				"description": "Cosmos DB account name"
			}
		},
		"location": {
			"type": "string",
			"defaultValue": "[resourceGroup().location]",
			"metadata": {
				"description": "Location for the Cosmos DB account."
			}
		},
		"primaryRegion":{
			"type":"string",
			"defaultValue": "eastus",
			"metadata": {
				"description": "Primary replica region for the Cosmos DB account."
			}
		},
		"secondaryRegion":{
			"type":"string",
			"defaultValue": "westus",
			"metadata": {
			  "description": "Secondary replica region for the Cosmos DB account."
		  }
		},
		"defaultConsistencyLevel": {
			"type": "string",
			"defaultValue": "Session",
			"allowedValues": [ "Eventual", "ConsistentPrefix", "Session", "BoundedStaleness", "Strong" ],
			"metadata": {
				"description": "The default consistency level of the Cosmos DB account."
			}
		},
		"maxStalenessPrefix": {
			"type": "int",
			"defaultValue": 100000,
			"minValue": 10,
			"maxValue": 2147483647,
			"metadata": {
				"description": "Max stale requests, required for BoundedStaleness. Valid ranges, Single Region: 10 to 1000000. Multi Region: 100000 to 1000000."
			}
		},
		"maxIntervalInSeconds": {
			"type": "int",
			"defaultValue": 300,
			"minValue": 5,
			"maxValue": 86400,
			"metadata": {
				"description": "Max lag time ( in seconds), required for BoundedStaleness. Valid ranges, Single Region: 5 to 84600. Multi Region: 300 to 86400."
			}
		},	
		"multipleWriteLocations": {
			"type": "bool",
			"defaultValue": false,
			"allowedValues": [ true, false ],
			"metadata": {
				"description": "Enable multi-master to make all regions writable."
			}
		},
		"databaseName": {
			"type": "string",
			"metadata": {
				"description": "The name for the Mongo DB database"
			}
		},
		"throughput": {
			"type": "int",
			"defaultValue": 400,
			"minValue": 400,
			"maxValue": 1000000,
			"metadata": {
				"description": "The shared throughput for the Mongo DB database"
			}			
		},
		"collection1Name": {
			"type": "string",
			"metadata": {
				"description": "The name for the first Mongo DB collection"
			}
		},
		"collection2Name": {
			"type": "string",
			"metadata": {
				"description": "The name for the second Mongo DB collection"
			}
		}
	},
	"variables": {
		"accountName": "[toLower(parameters('accountName'))]",
		"consistencyPolicy": {
			"Eventual": {
				"defaultConsistencyLevel": "Eventual"
			},
			"ConsistentPrefix": {
				"defaultConsistencyLevel": "ConsistentPrefix"
			},
			"Session": {
				"defaultConsistencyLevel": "Session"
			},
			"BoundedStaleness": {
				"defaultConsistencyLevel": "BoundedStaleness",
				"maxStalenessPrefix": "[parameters('maxStalenessPrefix')]",
				"maxIntervalInSeconds": "[parameters('maxIntervalInSeconds')]"
			},
			"Strong": {
				"defaultConsistencyLevel": "Strong"
			}
		},
		"locations": 
		[ 
			{
				"locationName": "[parameters('primaryRegion')]",
				"failoverPriority": 0,
				"isZoneRedundant": false
			}, 
			{
				"locationName": "[parameters('secondaryRegion')]",
				"failoverPriority": 1,
				"isZoneRedundant": false
			}
		]
	},
	"resources": 
	[
		{
			"type": "Microsoft.DocumentDB/databaseAccounts",
			"name": "[variables('accountName')]",
			"apiVersion": "2019-08-01",
			"location": "[parameters('location')]",
			"kind": "MongoDB",
			"properties": {
				"consistencyPolicy": "[variables('consistencyPolicy')[parameters('defaultConsistencyLevel')]]",
				"locations": "[variables('locations')]",
				"databaseAccountOfferType": "Standard",
				"enableMultipleWriteLocations": "[parameters('multipleWriteLocations')]"
			}
		},
		{
			"type": "Microsoft.DocumentDB/databaseAccounts/mongodbDatabases",
			"name": "[concat(variables('accountName'), '/', parameters('databaseName'))]",
			"apiVersion": "2019-08-01",
			"dependsOn": [ "[resourceId('Microsoft.DocumentDB/databaseAccounts/', variables('accountName'))]" ],
			"properties":{
				"resource":{
					"id": "[parameters('databaseName')]"
				},
				"options": { "throughput": "[parameters('throughput')]" }
			}
		},
		{
			"type": "Microsoft.DocumentDb/databaseAccounts/mongodbDatabases/collections",
			"name": "[concat(variables('accountName'), '/', parameters('databaseName'), '/', parameters('collection1Name'))]",
			"apiVersion": "2019-08-01",
			"dependsOn": [ "[resourceId('Microsoft.DocumentDB/databaseAccounts/mongodbDatabases', variables('accountName'), parameters('databaseName'))]" ],
			"properties":
			{
				"resource":{
					"id":  "[parameters('collection1Name')]",
					"shardKey": { "user_id": "Hash" },
					"indexes": [
						{
							"key": { "keys":["user_id", "user_address"] },
							"options": { "unique": "true" }
						},
						{
							"key": { "keys":["_ts"] },
							"options": { "expireAfterSeconds": "2629746" }
						}
					],
					"options": {
						"If-Match": "<ETag>"
					}
				}
			}
		},
		{
			"type": "Microsoft.DocumentDb/databaseAccounts/mongodbDatabases/collections",
			"name": "[concat(variables('accountName'), '/', parameters('databaseName'), '/', parameters('collection2Name'))]",
			"apiVersion": "2019-08-01",
			"dependsOn": [ "[resourceId('Microsoft.DocumentDB/databaseAccounts/mongodbDatabases', variables('accountName'),  parameters('databaseName'))]" ],
			"properties":
			{
				"resource":{
					"id":  "[parameters('collection2Name')]",
					"shardKey": { "company_id": "Hash" },
					"indexes": [
						{
							"key": { "keys":["company_id", "company_address"] },
							"options": { "unique": "true" }
						},
						{
							"key": { "keys":["_ts"] },
							"options": { "expireAfterSeconds": "2629746" }
						}
					],
					"options": {
						"If-Match": "<ETag>"
					}
				}
			}
		}
	]
}
```

## MongoDB Admin Tools

Once your deployment is complete, you should connect to your Cosmos DB instance with a standard MongoDB tool. You can use any of the third party MongoDB consoles to talk to the MongoDB API on your Cosmos DB instance, including:

- **Compass** - which is free from MongoDB (the company), available [HERE](https://www.mongodb.com/download-center/compass)
- **Studio 3T (recommended)** - This is the best tool in my experience, but comes at a price after the trial is over. You can download the trial [HERE](https://studio3t.com/)

> **NOTE:** Microsoft offers a tutorial on using Studio 3T with Cosmos DB [HERE](https://docs.microsoft.com/en-us/azure/cosmos-db/mongodb-mongochef) on Microsoft docs.

## Conclusion

I hope this is a useful addition to your Azure Infrastructure-as-Code arsenal. As always, if there is a specific topic you'd like to see, just open an issue on the 100 Days repo.