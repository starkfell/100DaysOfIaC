# Day XXX - Build Pipelines, using a Service Principal to access Resources in a Task (Linux Edition)

In today's article we are going to cover how to access resources in an Azure CLI Task in a Build Pipeline. The methods demonstrated in this article can also be used for several other IaaS and PaaS Offerings available in Azure.

> **NOTE:** This article was tested and written for an Azure Build Pipeline using a Microsoft-hosted Agent running Ubuntu 18.04 and a separate Linux Host running Ubuntu 18.04 with Azure CLI installed.

## Create a Service Principal

On your Linux Host (with Azure CLI installed), open up a bash prompt and run the following command to create a new Service Principal.

```bash
AZURE_SP=$(/usr/bin/az ad sp create-for-rbac \
--role "contributor" \
--name "sp-for-iam-access" \
--years 3)
```

You should get back a result similar to what is shown below.

```console
Changing "sp-for-iam-access" to a valid URI of "http://sp-for-iam-access", which is the required format used for service principal names
Creating a role assignment under the scope of "/subscriptions/00000000-0000-0000-0000-000000000000"
  Retrying role assignment creation: 1/36
  Retrying role assignment creation: 2/36
```

<br />

Assign the contributor role to the new Service Principal for the Storage Account.

```bash
# Assigning the Kubernetes Cluster Service Principal as a Contributor to the Monitoring Resource Group.
ASSIGN_ROLE=$(az role assignment create \
--role "Contributor" \
--assignee "http://$K8S_CLUSTER_SP_USERNAME" \
--resource-group "$K8S_MONITORING_RESOURCE_GROUP_NAME" 2>&1)
```

Retrieve the **appId** from the Azure Service Principal.

```bash
echo $AZURE_SP | jq .appId | tr -d '"'
```

You should get back the **appId** which should look similar to what is shown below, make a note of it.

```console
3decfe16-a3a1-4e4a-80f6-f834297a7d42
```

<br />

Retrieve the **password** from the Azure Service Principal.

```bash
echo $AZURE_SP | jq .password | tr -d '"'
```

You should get back the **password** which should look similar to what is shown below, make a note of it.

```console
02ab477d-b64d-4ef8-9a16-5bcbe8652036
```

<br />

Next, open up your Azure Build Pipeline and create a new Azure CLI task called **retrieve-storage-account-key-using-iam** and then click on **Manage** in the *Azure Subscription* section.

![001](../images/_daydraft2/day.xxx.build.pipes.sp.resource.access.001.png)

<br />

In the Service Connections blade, click on **New Service Connection** and then on **Azure Resource Manager**.

![002](../images/_daydraft2/day.xxx.build.pipes.sp.resource.access.002.png)

<br />

Next, in the **Add an Azure Resource Manager service connection** window, click on the link **use the full version of the service connection dialog**.

![003](../images/_daydraft2/day.xxx.build.pipes.sp.resource.access.003.png)

<br />

Next, in the **Add an Azure Resource Manager service connection** window, set the *Connection name* field to **retrieve-storage-account-key-using-iam**. Paste in the **appId** value from earlier in the *Service principal client ID* field and the **password** value in the *Service principal key* field. Afterwards, click on the **Verify connection** button. Once the connection is verified, click on the **OK** button.

![004](../images/_daydraft2/day.xxx.build.pipes.sp.resource.access.004.png)

<br />

Back in your Azure CLI task window, click on the **Refresh Azure subscription** button.

![005](../images/_daydraft2/day.xxx.build.pipes.sp.resource.access.005.png)

<br />

In the **Azure subscription** field, click on the drop-down arrow and select **retrieve-storage-account-key-using-iam** under *Available Azure service connections*.

![006](../images/_daydraft2/day.xxx.build.pipes.sp.resource.access.006.png)

<br />

Next, copy and paste in the code below into the inline Script section and then click on **Save & queue**.

```bash
# Displaying the Storage Account Primary Key Value using IAM Access by adding the Service Principal to the Storage Account.
az storage account keys list \
--account-name encryptvardemow1gc \
--query [0].value \
--output tsv
```

> **NOTE** Replace the value under the *--account-name* parameter with the name of your storage account!

![007](../images/_daydraft2/day.xxx.build.pipes.sp.resource.access.007.png)

## Conclusion

Blah blah Blah