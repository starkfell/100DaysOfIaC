# Day 999 Random Notes

[Update the permissions of the Service Principal used for the Build Pipeline](#update-the-permissions-of-the-service-principal-used-for-the-build-pipeline)</br>


## Update the permissions of the Service Principal used for the Build Pipeline

The primary reason we are updating the permissions of the **sp-az-build-pipeline-creds** Service Principal is because the following error can occur if it doesn't have Owner access rights to an Azure Container Registry when attempting to deploy an image from it.

```console
ERROR: The image 'pracazconreg.azurecr.io/practical/nginx:latest' in container group 'nginx-iac-001' is not accessible. Please check the image and registry credential.
```

> **NOTE:** The section in **[Part 1](./day.35.building.a.practical.yaml.pipeline.part.1.md)** where the Service Principal **sp-az-build-pipeline-creds** is initially created has been updated to use the **Owner** Role instead of **Contributor**.

</br>

You can use one of the two options below to update the **sp-az-build-pipeline-creds** Service Principal.

</br>

### Option 1

Login to the Azure Portal and browse to the **pracazconreg** Azure Container Registry, click on **Access Control (IAM)** and then change the Role Assignment of the **sp-az-build-pipeline-creds** Service Principal from **Contributor** to **Owner**.

> **NOTE:** This option only grants **Owner** access to the Azure Container Registry resource. While from a security perspective this is good, from an idempotent standpoint, its horrific as you would have to manually update the permissions of the Azure Container Registry again if you had to redeploy it from scratch.

</br>

### Option 2

On your Linux Host (with Azure CLI installed), open up a bash prompt and run the following command to change the Role of the **pracazconreg** Service Principal from **Contributor** to **Owner** in the Azure Subscription.

```bash
az role assignment create \
--assignee http://sp-az-build-pipeline-creds \
--role Owner
```

You should back the following response.

```json
{
  "canDelegate": null,
  "id": "/subscriptions/00000000-0000-0000-0000-000000000000/providers/Microsoft.Authorization/roleAssignments/0a11bb78-e40d-4f1f-87c3-dcea4011dfb8",
  "name": "0a11bb78-e40d-4f1f-87c3-dcea4011dfb8",
  "principalId": "3e812ebf-bc38-42d8-bd6a-fa7439d00435",
  "principalName": "http://sp-az-build-pipeline-creds",
  "principalType": "ServicePrincipal",
  "roleDefinitionId": "/subscriptions/00000000-0000-0000-0000-000000000000/providers/Microsoft.Authorization/roleDefinitions/8e3af657-a8ff-443c-a75c-2fe8c4bcb635",
  "roleDefinitionName": "Owner",
  "scope": "/subscriptions/00000000-0000-0000-0000-000000000000",
  "type": "Microsoft.Authorization/roleAssignments"
}
```

> **NOTE:** This option grants **Owner** access the entire Azure Subscription. From a security perspective, this may make some people very uneasy; however, from an automation and governance perspective, this is much easier to manage and maintain as compared to a regular user account with Full Access to the Azure Subscription that's associated with an actual, visible user account.

</br>

Next, run the following command to remove the **Contributor** Access from the Service Principal. You won't get any output returned after running the command.

```bash
az role assignment delete \
--assignee http://sp-az-build-pipeline-creds \
--role Contributor
```

</br>
