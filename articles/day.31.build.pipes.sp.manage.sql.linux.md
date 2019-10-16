# Day 31 - Build Pipelines, using a Service Principal to manage SQL Resources (Linux Edition)

In today's article we are going to cover how to create and restrict a Service Principal to manage SQL Resources in a Build Pipeline.

> **NOTE:** This article was tested and written for an Azure Build Pipeline using a Microsoft-hosted Agent running Ubuntu 18.04 and a separate Linux Host running Ubuntu 18.04 with Azure CLI installed.

**In this article:**

[Create a new Resource Group and an Azure Key Vault](#create-a-new-resource-group-and-an-azure-key-vault) </br>
[Create a Service Principal](#create-a-service-principal) </br>
[Grant the Service Principal Access to the Key Vault Secrets](#grant-the-service-principal-access-to-the-key-vault-secrets) </br>
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
RANDOM_ALPHA=$(cat /dev/urandom | tr -dc 'a-z0-9' | fold -w 4 | head -n 1)
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
--name "sp-for-rg-sp-sql-controlled" \
--scope "/subscriptions/$AZURE_SUB_ID/resourceGroups/sp-sql-controlled" \
--years 1)
```

You should get back a result similar to what is shown below. You'll notice that the **contributor** right assignment is scoped to the Resource Group.

```console
Changing "sp-for-rg-sp-sql-controlled" to a valid URI of "http://sp-for-rg-sp-sql-controlled", which is the required format used for service principal names
Creating a role assignment under the scope of "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/sp-sql-controlled"
  Retrying role assignment creation: 1/36
  Retrying role assignment creation: 2/36
```

<br />

Retrieve the **appId** from the Azure Service Principal.

```bash
echo $AZURE_SP | jq .appId | tr -d '"'
```

You should get back the **appId** which should look similar to what is shown below, make a note of it.

```console
0e4067a6-667d-4f77-a58e-31256ab3c0dc
```

<br />

Retrieve the **password** from the Azure Service Principal.

```bash
echo $AZURE_SP | jq .password | tr -d '"'
```

You should get back the **password** which should look similar to what is shown below, make a note of it.

```console
a19e6d9a-f72b-4203-9ecc-b019aac0a2db
```

<br />

Next, open up your Azure Build Pipeline and create a new Azure CLI task called **manage-sql-using-sp** and then click on **Manage** in the *Azure Subscription* section.

![001](../images/day31/day.31.build.pipes.sp.resource.access.linux.001.png)

<br />

In the Service Connections blade, click on **New Service Connection** and then on **Azure Resource Manager**.

![002](../images/day31/day.31.build.pipes.sp.resource.access.linux.002.png)

<br />

Next, in the **Add an Azure Resource Manager service connection** window, click on the link **use the full version of the service connection dialog**.

![003](../images/day31/day.31.build.pipes.sp.resource.access.linux.003.png)

<br />

Next, in the **Add an Azure Resource Manager service connection** window, set the *Connection name* field to **manage-sql-using-sp**. Paste in the **appId** value from earlier in the *Service principal client ID* field and the **password** value in the *Service principal key* field. Afterwards, click on the **Verify connection** button. Once the connection is verified, click on the **OK** button.

![004](../images/day31/day.31.build.pipes.sp.resource.access.linux.004.png)

<br />

Back in your Azure CLI task window, click on the **Refresh Azure subscription** button.

![005](../images/day31/day.31.build.pipes.sp.resource.access.linux.005.png)

<br />

In the **Azure subscription** field, click on the drop-down arrow and select **manage-sql-using-sp** under *Available Azure service connections*.

![006](../images/day31/day.31.build.pipes.sp.resource.access.linux.006.png)

<br />

Next, copy and paste in the code below into the inline Script section and then click on **Save & queue**.

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

    echo "DB Name: $DB, Current Size: $((DB_CURRENT_SIZE/1024))MB"
done
```

![007](../images/day31/day.31.build.pipes.sp.resource.access.linux.007.png)

<br />

When the job has completed, you should see the Storage Account Primary Key in the Job Logs.

![008](../images/day31/day.31.build.pipes.sp.resource.access.linux.008.png)

<br />

## Things to Consider

We created a Service Principal manually instead of automatically so that you can easily locate the Service Principal in the Azure Portal. Service Principals that are created automatically in the **Add an Azure Resource Manager service connection** are given a name that is non-descriptive following by a GUID. Trying to manage these types Service Principals can be very cumbersome and time consuming.

The Service Principal that we created has *Contributor* rights across the entire Subscription because of the way that we created it here. By utilizing the *--scope* switch in the **az ad sp create-for-rbac**, you can restrict a Service Principal down to a specific resource if necessary.

In the Azure Key Vault task, values retrieved from the targeted key vault are retrieved as strings and a task variable is created with the latest value of the respective secret being fetched. This is why the task variable is called *$(iac-secret-demo)* for the *iac-secret-demo* Secret in the key vault.

<br />

## Conclusion

In today's article we covered how to access Azure resources using a Service Principal that was granted IAM access and how that would behave in an Azure CLI Task in a Build Pipeline. If there's a specific scenario that you wish to be covered in future articles, please create a **[New Issue](https://github.com/starkfell/100DaysOfIaC/issues)** in the [starkfell/100DaysOfIaC](https://github.com/starkfell/100DaysOfIaC/) GitHub repository.
