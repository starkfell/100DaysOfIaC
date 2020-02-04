# Day 92 - Restricting Network Access to Azure Database for PostgreSQL

Today we will cover how to restrict access to an Azure Database for PostgreSQL using VNet Rules.

</br>

> **NOTE:** This article was tested and written for a Linux Host running Ubuntu 18.04 with Azure CLI installed.

</br>

This article covers the same network environment circumstances (restricting access) as described in [Day 90](./day.90.restricting.network.access.to.key.vault.md) but with the focus on Azure Database for PostgreSQL.The walkthrough below will demonstrate how to restrict network access to an Azure Database for PostgreSQL.

> **NOTE:** If you are following these instructions directly after [Day 90](./day.90.restricting.network.access.to.key.vault.md), many of the steps below can be skipped since some of the infrastructure will already be in place.

</br>

In today's article we will be performing the following steps.

[Install psql](#install-psql)</br>
[Deploy a new Resource Group](#deploy-a-new-resource-group)</br>
[Deploy a VNet](#deploy-a-vnet)</br>
[Add the Service Endpoint for Microsoft.ContainerRegistry to the VNet](#add-the-service-endpoint-for-microsoftcontainerregistry-to-the-vnet)</br>
[Deploy an Azure Database for PostgreSQL](#deploy-an-azure-container-registry)</br>
[Restrict access to the Azure Container Registry](#restrict-access-to-the-azure-container-registry)</br>
[Verify Restricted Access to the Azure Container Registry](#verify-restricted-access-to-the-azure-container-registry)</br>
[Things to Consider](#things-to-consider)</br>
[Conclusion](#conclusion)</br>

## Install psql

**psql** is a terminal-based front-end tool that allows you to login and interactively work with PostgreSQL. We need it to verify restricted connectivity to our PostgresSQL Databases later on in the article.

Run the following command to install the **psql** client on your Ubuntu Host.

```bash
sudo apt-get install -y \
postgresql-client-common \
postgresql-client
```

You should get back a similar response as shown below.

```console
Reading package lists... Done
Building dependency tree
Reading state information... Done
The following additional packages will be installed:
  postgresql-client-10
Suggested packages:
  postgresql-10 postgresql-doc-10
The following NEW packages will be installed:
  postgresql-client postgresql-client-10 postgresql-client-common
0 upgraded, 3 newly installed, 0 to remove and 82 not upgraded.
Need to get 0 B/971 kB of archives.
After this operation, 3,444 kB of additional disk space will be used.
Selecting previously unselected package postgresql-client-common.
(Reading database ... 183718 files and directories currently installed.)
Preparing to unpack .../postgresql-client-common_190ubuntu0.1_all.deb ...
Unpacking postgresql-client-common (190ubuntu0.1) ...
Selecting previously unselected package postgresql-client-10.
Preparing to unpack .../postgresql-client-10_10.10-0ubuntu0.18.04.1_amd64.deb ...
Unpacking postgresql-client-10 (10.10-0ubuntu0.18.04.1) ...
Selecting previously unselected package postgresql-client.
Preparing to unpack .../postgresql-client_10+190ubuntu0.1_all.deb ...
Unpacking postgresql-client (10+190ubuntu0.1) ...
Setting up postgresql-client-common (190ubuntu0.1) ...
Processing triggers for man-db (2.8.3-2ubuntu0.1) ...
Setting up postgresql-client-10 (10.10-0ubuntu0.18.04.1) ...
update-alternatives: using /usr/share/postgresql/10/man/man1/psql.1.gz to provide /usr/share/man/man1/psql.1.gz (psql.1.gz) in auto mode
Setting up postgresql-client (10+190ubuntu0.1) ...
```

</br>

## Deploy a new Resource Group

Using Azure CLI, run the following command to create a new Resource Group.

```bash
az group create \
--name 100days-lockdown \
--location westeurope
```

You should get back the following output:

```json
{
  "id": "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/100days-lockdown",
  "location": "westeurope",
  "managedBy": null,
  "name": "100days-lockdown",
  "properties": {
    "provisioningState": "Succeeded"
  },
  "tags": null,
  "type": "Microsoft.Resources/resourceGroups"
}
```

</br>

## Deploy a VNet

Next, run the following command to create a new VNet in the Resource Group.

```bash
az network vnet create \
--name "100days-lockdown-vnet" \
--resource-group "100days-lockdown" \
--address-prefix "172.16.0.0/16" \
--subnet-name "100days-lockdown-subnet" \
--subnet-prefix "172.16.1.0/24" \
--query "newVNet.provisioningState" \
--output tsv
```

You should get back a similar response.

```console
"Succeeded"
```

</br>

## Add the Service Endpoint for Microsoft.SQL to the VNet

Next, Open up the [Azure Portal](https://portal.azure.com) and browse to **100days-lockdown-vnet** in the **100days-lockdown** Resource Group. Browse to the **Service endpoints** under **Settings** and click on the **+ Add** at the top. Next, in the **Service** drop-down menu, choose *Microsoft.SQL* and in the **Subnets** drop-down menu choose *100days-lockdown-subnet*.

![001](../images/day92/day.92.restricting.network.access.to.az.postgres.001.png)

</br>

When you are done, click on the **Add** button at the bottom. The Service Endpoint will take only a few seconds to apply.

</br>

## Deploy an Azure PostgreSQL Server

Run the following command to generate a random Password for the PostgreSQL Server

```bash
POSTGRES_SERVER_ADMIN_PASSWORD=$(cat /proc/sys/kernel/random/uuid 2>&1)
```

Next, run the following command to create a new Azure PostgreSQL Server in the Resource Group.

```bash
az postgres server create \
--name "100dayspostgres" \
--admin-user "pgadmin" \
--admin-password "$POSTGRES_SERVER_ADMIN_PASSWORD" \
--location "westeurope" \
--resource-group "100days-lockdown" \
--sku-name GP_Gen5_2 \
--version 11 \
--query userVisibleState \
--output tsv
```

You should get back the following response.

```console
Ready
```

> **NOTE:** You have to use the General Purpose or higher SKU for Azure Database for PostgreSQL in order to use VNet Rules.

</br>

## Restrict access to the Azure PostgreSQL Server

Run the following command to retrieve the Subnet ID of the **100days-lockdown-subnet** subnet.

```bash
SUBNET_ID=$(az network vnet subnet list \
--resource-group "100days-lockdown" \
--vnet-name "100days-lockdown-vnet" \
| jq '.[].id | select(.|test("lockdown"))' | tr -d '"')
```

</br>

Next, run the following command to create a VNet Rule in the Azure PostgresSQL Server restricting access only from the **100days-lockdown-subnet** subnet.

```bash
/usr/bin/az postgres server vnet-rule create \
--name "100days-lockdown-subnet" \
--server-name "100dayspostgres" \
--resource-group "100days-lockdown" \
--subnet $SUBNET_ID \
--query state \
--output tsv
```

You should get back the following response

```console
Ready
```

</br>

## Verify Restricted Access to the Azure PostgresSQL Server

Finally, run the following **psql** command to verify that you can no longer access the Azure PostgresSQL Server from outside of the **100days-lockdown-subnet** Subnet.

```bash
psql "host=100dayspostgres.postgres.database.azure.com port=5432 dbname=user_ user=pgadmin@100dayspostgres password=$POSTGRES_SERVER_ADMIN_PASSWORD sslmode=require"
```

You should get back a response similar to what is shown below.

```console
psql: FATAL:  no pg_hba.conf entry for host "000.000.000.000", user "pgadmin", database "user_", SSL on
```

</br>

## Things to Consider

Keep in mind that the VNet Rule(s) that we put in place *only* restrict access to the Databases in the Azure PostgreSQL Server. If you browse to the Azure PostgresSQL Server instance in the [Azure Portal](https://portal.azure.com), you'll notice that you'll still have access to the **Settings** of the PostgreSQL Server as this level of access is controlled using Azure Identity and Access Management (IAM).

If you want enable yourself to connect to the **postgres** database instance, you can browse to the Azure PostgresSQL Server instance in the [Azure Portal](https://portal.azure.com), go to **Settings** and then **Connection security** and add your Public IP Address by clicking on the **+ Add client IP** button.

</br>

## Conclusion

In today's article we covered how to restrict access to an Azure PostgresSQL Server using Network Rules. If there's a specific scenario that you wish to be covered in future articles, please create a **[New Issue](https://github.com/starkfell/100DaysOfIaC/issues)** in the [starkfell/100DaysOfIaC](https://github.com/starkfell/100DaysOfIaC/) GitHub repository.
