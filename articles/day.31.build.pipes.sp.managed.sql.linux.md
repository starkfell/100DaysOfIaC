# Day 31 - Build Pipelines, using a Service Principal to manage SQL Resources (Linux Edition)

In today's article we are going to cover how to create and restrict a Service Principal to manage SQL Resources in a Build Pipeline. In Azure DevOps, you have several options natively available and in the Marketplace for deploying and managing SQL in Azure. We hope that the walkthrough below provides you with another method to add to your existing arsenal when you are determining what options are available for in a Build Pipeline.

> **NOTE:** This article was tested and written for an Azure Build Pipeline using a Microsoft-hosted Agent running Ubuntu 18.04 and a separate Linux Host running Ubuntu 18.04 with Azure CLI installed.

**In this article:**

[Create a Resource Group, SQL Server and SQL DB](#create-a-resource-group-sql-server-and-sql-db) </br>
[Create a Service Principal](#create-a-service-principal) </br>
[Configure the Build Pipeline](#configure-the-build-pipeline) </br>
[Things to Consider](#things-to-consider) </br>
[Conclusion](#conclusion) </br>

## Create a Resource Group, SQL Server and SQL DB

<br />

On your Linux Host (with Azure CLI installed), open up a bash prompt and run the following command to create a new Resource Group.

```bash
az group create \
--name sp-sql-controlled \
--location westeurope
```

You should get back the following output:

```console
{
  "id": "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/sp-sql-controlled",
  "location": "westeurope",
  "managedBy": null,
  "name": "sp-sql-controlled",
  "properties": {
    "provisioningState": "Succeeded"
  },
  "tags": null,
  "type": "Microsoft.Resources/resourceGroups"
}
```

<br />

Next, run the following command randomly generate 4 alphanumeric characters.

```bash
RANDOM_ALPHA=$(LC_CTYPE=C tr -dc 'a-z0-9' < /dev/urandom | fold -w 4 | head -n 1)
```

> **NOTE:** We are appending this to the name of our Azure SQL Server and DB to ensure uniqueness.

<br />

Next, run the following command to create a new Azure SQL Server.

```bash
NEW_SQL_SERVER=$(az sql server create \
--admin-user "spsrvdemo" \
--admin-password "D0NotU2E1nPr0duct1on1!" \
--name "spsqlsrv${RANDOM_ALPHA}" \
--resource-group sp-sql-controlled \
--location westeurope)
```

The previous action will display the following output for a minute or two:

```console
 - Running ..
```

<br />

Run the following command to verify that the Azure SQL Server was provisioned successfully.

```bash
echo $NEW_SQL_SERVER | jq .state
```

You should get back the following output:

```console
"Ready"
```

<br />

Next, run the following command to create a new Azure SQL DB.

```bash
NEW_SQL_DB=$(az sql db create \
--name "spsqldb${RANDOM_ALPHA}" \
--server "spsqlsrv${RANDOM_ALPHA}" \
--resource-group sp-sql-controlled \
--edition Basic \
--sample-name AdventureWorksLT \
--capacity 5)
```

The previous action will display the following output for a minute or two:

```console
 - Running ..
```

<br />

Run the following command to verify that the Azure SQL DB was provisioned successfully.

```bash
echo $NEW_SQL_DB | jq .status
```

You should get back the following output:

```console
"Online"
```

<br />

## Create a Service Principal

Next, run the following to retrieve your Azure Subscription ID and store it in a variable.

```bash
AZURE_SUB_ID=$(az account show --query id --output tsv)
```

If the above command doesn't work, manually add your Azure Subscription ID to the variable.

```powershell
AZURE_SUB_ID=("00000000-0000-0000-0000-000000000000")
```

On your Linux Host (with Azure CLI installed), open up a bash prompt and run the following command to create a new Service Principal.

```bash
AZURE_RESOURCE_SP=$(/usr/bin/az ad sp create-for-rbac \
--role "contributor" \
--name "rg-sp-sql-controlled" \
--scope "/subscriptions/$AZURE_SUB_ID/resourceGroups/sp-sql-controlled" \
--years 1)
```

You should get back a result similar to what is shown below. You'll notice that the **contributor** right assignment is scoped to the Resource Group.

```console
Changing "rg-sp-sql-controlled" to a valid URI of "http://rg-sp-sql-controlled", which is the required format used for service principal names
Creating a role assignment under the scope of "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/sp-sql-controlled"
  Retrying role assignment creation: 1/36
  Retrying role assignment creation: 2/36
```

<br />

Retrieve the **appId** from the Azure Service Principal.

```bash
echo $AZURE_RESOURCE_SP | jq .appId | tr -d '"'
```

You should get back the **appId** which should look similar to what is shown below, make a note of it.

```console
0e4067a6-667d-4f77-a58e-31256ab3c0dc
```

<br />

Retrieve the **password** from the Azure Service Principal.

```bash
echo $AZURE_RESOURCE_SP | jq .password | tr -d '"'
```

You should get back the **password** which should look similar to what is shown below, make a note of it.

```console
a19e6d9a-f72b-4203-9ecc-b019aac0a2db
```

<br />

## Configure the Build Pipeline

Next, open up your Azure Build Pipeline and create a new Azure CLI task called **manage-sql-using-sp** and then click on **Manage** in the *Azure Subscription* section.

![001](../images/day31/day.31.build.pipes.sp.managed.sql.linux.001.png)

<br />

In the Service Connections blade, click on **New Service Connection** and then on **Azure Resource Manager**.

![002](../images/day31/day.31.build.pipes.sp.managed.sql.linux.002.png)

<br />

Next, in the **Add an Azure Resource Manager service connection** window, click on the link **use the full version of the service connection dialog**.

![003](../images/day31/day.31.build.pipes.sp.managed.sql.linux.003.png)

<br />

Next, in the **Add an Azure Resource Manager service connection** window, set the *Connection name* field to **rg-sp-sql-controlled**. Paste in the **appId** value from earlier in the *Service principal client ID* field and the **password** value in the *Service principal key* field. Afterwards, click on the **Verify connection** button. Once the connection is verified, click on the **OK** button.

![004](../images/day31/day.31.build.pipes.sp.managed.sql.linux.004.png)

<br />

Back in your Azure CLI task window, click on the **Refresh Azure subscription** button.

![005](../images/day31/day.31.build.pipes.sp.managed.sql.linux.005.png)

<br />

In the **Azure subscription** field, click on the drop-down arrow and select **rg-sp-sql-controlled** under *Available Azure service connections*.

![006](../images/day31/day.31.build.pipes.sp.managed.sql.linux.006.png)

<br />

Next, copy and paste in the code below into the inline Script section and then click on **Save & queue**. The purpose of this script is to retrieve the current size of all existing SQL Databases in on the SQL Server in the Resource Group.

```bash
# Managing the SQL Database in the 'sp-sql-controlled' Resource Group with a Service Principal.
SQL_SERVER_NAME=$(az sql server list \
--resource-group sp-sql-controlled \
| jq .[].name \
| tr -d '"')

SQL_DBS=$(az sql db list \
--resource-group sp-sql-controlled \
--server $SQL_SERVER_NAME \
| jq .[].name \
| tr -d '"')

for DB in $SQL_DBS
do
    DB_CURRENT_SIZE=$(az sql db list-usages \
    --name $DB \
    --resource-group sp-sql-controlled \
    --server $SQL_SERVER_NAME \
    | jq .[0].currentValue)

    echo "DB Name: $DB, Current Size: $((DB_CURRENT_SIZE/1048576))MB"
done
```

<br />

![007](../images/day31/day.31.build.pipes.sp.managed.sql.linux.007.png)

<br />

When the job has completed, you should see the Storage Account Primary Key in the Job Logs.

![008](../images/day31/day.31.build.pipes.sp.managed.sql.linux.008.png)

<br />

## Things to Consider

The Service Principal we created is specifically targeting the Resource Group where the SQL Server and Databases are deployed. You can technically narrow down the Service Principal's access even further to the SQL Server and/or database; however, what kind of actions you'll be able to take may be more restricted than you intended.

The inline script that we provided is used to illustrate the types of options you have available to you. You could also do things such as checking a database for an existing set of columns or entries and then perform some type of action based on the results in the task(s) that follow.

<br />

## Conclusion

In today's article we covered how to create and restrict a Service Principal to manage SQL Resources in a Build Pipeline. If there's a specific scenario that you wish to be covered in future articles, please create a **[New Issue](https://github.com/starkfell/100DaysOfIaC/issues)** in the [starkfell/100DaysOfIaC](https://github.com/starkfell/100DaysOfIaC/) GitHub repository.
