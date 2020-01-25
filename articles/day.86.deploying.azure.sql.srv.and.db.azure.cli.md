# Day 86 - Deploying an Azure SQL Server and Database using the Azure CLI

Today we will cover how to deploy an Azure  and a Web Application in Azure using ARM and how to automatically connect the two.

</br>

In today's article we will cover the following scenarios when troubleshooting your Kubernetes Applications using **kubectl**.

[Deploy a new Resource Group](#deploy-a-new-resource-group)</br>
[Create the ARM Template File](#create-the-arm-template-file)</br>
[Deploy the ARM Template](#deploy-the-arm-template)</br>
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

## Deploy the Azure SQL Server

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

# Upload a test Database to the SQL Server

Download stuff

https://github.com/Microsoft/sql-server-samples/releases/download/adventureworks/AdventureWorks2017.bak

