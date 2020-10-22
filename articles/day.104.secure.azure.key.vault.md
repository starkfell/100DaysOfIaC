# Day 104 - Azure Key Vault Security and Automation (in plain English)

In this session, we'll break down security for Azure Key Vault end-to-end in a variety of scenarios. Resources from this session are detailed below, along with the link to the video on YouTube.

## In this article:

- [YouTube Video](#youtube-video)</br>
- [Related Installments](#related-installments)</br>
- [Related Articles and Tutorials](#related-articles-and-tutorials)</br>
- [Azure Cloud Shell transcript](#azure-cloud-shell-transcript) (from live session)</br>

***
SPONSOR: Need to stop and start your development VMs on a schedule? The Azure Resource Scheduler let's you schedule up to 10 Azure VMs for FREE! Learn more [HERE](https://azuremarketplace.microsoft.com/en-us/marketplace/apps/lumagatena.resourcescheduler?tab=Overview)
***

## YouTube Video

Watch the video on YouTube at [PENDING](https://youtu.be/)

**TO SUBSCRIBE:** Click **[HERE](https://www.youtube.com/channel/UCAr0yk0um7lwLjmrKfzwyig?sub_confirmation=1)** to follow us on Youtube so you get a heads up on future videos!

A few areas we covered in this video include:

- Management plane security (RBAC)
- Data plane security (access policies)
- Deployment and management automation
- Azure Pipelines integration
- Certificate integration and lifecycle management
- Backing up and recovering AKV contents

([back to top](#in-this-article))

## Related Installments

You will find some of the code samples shown in this session in the articles below:

[Day 90 - Restricting Network Access to Azure Key Vault](https://github.com/starkfell/100DaysOfIaC/blob/master/articles/day.90.restricting.network.access.to.key.vault.md)</br>

[Day 70 - Managing Access to Linux VMs using Azure Key Vault - Part 3](https://github.com/starkfell/100DaysOfIaC/blob/master/articles/day.70.manage.access.to.linux.vms.using.key.vault.part.3.md)</br>

[Day 69 - Managing Access to Linux VMs using Azure Key Vault - Part 2](https://github.com/starkfell/100DaysOfIaC/blob/master/articles/day.69.manage.access.to.linux.vms.using.key.vault.part.2.md)</br>

[Day 68 - Managing Access to Linux VMs using Azure Key Vault - Part 1](https://github.com/starkfell/100DaysOfIaC/blob/master/articles/day.68.manage.access.to.linux.vms.using.key.vault.part.1.md)</br>

[Day 28 - Build Pipelines, Fine Tuning access to a Key Vault (Linux Edition)](https://github.com/starkfell/100DaysOfIaC/blob/master/articles/day.28.build.pipes.sp.direct.access.to.key.vault.linux.md)</br>

[Day 27 - Build Pipelines, Fine Tuning access to a Key Vault (Windows Edition)](https://github.com/starkfell/100DaysOfIaC/blob/master/articles/day.27.build.pipes.sp.direct.access.to.key.vault.windows.md)</br>

[Day 26 - Build Pipelines, Key Vault Integration (Windows Edition)](https://github.com/starkfell/100DaysOfIaC/blob/master/articles/day.26.build.pipes.key.vault.windows.md)</br>

[Day 25 - Build Pipelines, Key Vault Integration (Linux Edition)](https://github.com/starkfell/100DaysOfIaC/blob/master/articles/day.25.build.pipes.key.vault.linux.md)</br>

([back to top](#in-this-article))

## Related Articles and Tutorials

Managed Identity in Azure DevOps Service Connections

https://stefanstranger.github.io/2019/03/02/ManageIdentityInServiceConnections/

Service connections (in Azure Pipelines)

https://docs.microsoft.com/en-us/azure/devops/pipelines/library/service-endpoints?view=azure-devops&tabs=yaml

Quickstart: Set and retrieve a secret from Azure Key Vault using the Azure portal (Azure CLI)

https://docs.microsoft.com/en-us/azure/key-vault/secrets/quick-create-cli

Quickstart: Set and retrieve a secret from Azure Key Vault using the Azure portal (PowerShell)

https://docs.microsoft.com/en-us/azure/key-vault/secrets/quick-create-powershell

Quickstart: Set and retrieve a secret from Azure Key Vault using an ARM template

https://docs.microsoft.com/en-us/azure/key-vault/secrets/quick-create-template?tabs=CLI

Use Key Vault from App Service with Managed Service Identity

https://docs.microsoft.com/en-us/samples/azure-samples/app-service-msi-keyvault-dotnet/keyvault-msi-appservice-sample/

## Azure Cloud Shell Transcript

The following are the highlights from the demos in Azure Cloud Shell

- Create Key Vault and Service Principal
  - Create a Key Vault instance
  - Create a Service Principal (SP)
- Grant Service Principal Access to Key Vault
  - Grant the SP access to the Key Vault
  - Grant the SP access to Key Vault secrets
  - Grant a managed identity KV access
- Set and retrieve a secret:
  - Set and retrieve from portal
  - Set and retrieve a secret from Cloud Shell (Azure CLI)

([back to top](#in-this-article))

### Create a new Resource Group and an Azure Key Vault

On your Linux Host (with Azure CLI installed), open up a bash prompt and run the following command to create a new Resource Group.

```bash
az group create \
--name fine-tune-access-key-vault \
--location westeurope
```

You should get back the following output.

```json
{
  "id": "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/fine-tune-access-key-vault",
  "location": "westeurope",
  "managedBy": null,
  "name": "fine-tune-access-key-vault",
  "properties": {
    "provisioningState": "Succeeded"
  },
  "tags": null,
  "type": "Microsoft.Resources/resourceGroups"
}
```

Next, run the following command randomly generate 4 alphanumeric characters.

```bash
RANDOM_ALPHA=$(cat /dev/urandom | tr -dc 'a-z0-9' | fold -w 4 | head -n 1)
```

> **NOTE:** We are appending this to the name of our Key Vault to ensure its name is unique.

Next, run the following command to create an Azure Key Vault in the new Resource Group.

```bash
az keyvault create \
--name "iacftvault${RANDOM_ALPHA}" \
--resource-group fine-tune-access-key-vault \
--location westeurope \
--output table
```

You should get back the following output when the task is finished.

```console
Location    Name            ResourceGroup
----------  --------------  ---------------------------------
westeurope  iacftvault31mr  fine-tune-access-key-vault
```

Next, add the following secret to the Key Vault.

```bash
az keyvault secret set --name iac-secret-demo \
--vault-name "iacftvault${RANDOM_ALPHA}" \
--value "100Days0fIaC1!" \
--output table
```

You should get back the following response.

```console
Value
--------------
100Days0fIaC1!
```

</br>

Next retrieve your Azure Subscription ID and store it in a variable.

```bash
AZURE_SUB_ID=$(az account show --query id --output tsv)
```

If the above command doesn't work, manually add your Azure Subscription ID to the variable.

```bash
AZURE_SUB_ID="00000000-0000-0000-0000-000000000000"
```

### Create a Service Principal

Next, run the following command to create a new Service Principal called **sp-restricted-keyvault-access** with no scope assignment.

```bash
AZURE_SP=$(az ad sp create-for-rbac \
--name "sp-restricted-keyvault-access" \
--role "reader" \
--scope "/subscriptions/$AZURE_SUB_ID/resourceGroups/fine-tune-access-key-vault/providers/Microsoft.KeyVault/vaults/iacftvault${RANDOM_ALPHA}" \
--years 1)
```

You should get back a result similar to what is shown below.

```console
Changing "sp-restricted-keyvault-access" to a valid URI of "http://sp-restricted-keyvault-access", which is the required format used for service principal names
Creating a role assignment under the scope of "/subscriptions/00000000-0000-0000-0000-000000000000"
  Retrying role assignment creation: 1/36
  Retrying role assignment creation: 2/36
```

Next, run the following command to retrieve the **appId** of the Azure Service Principal.

```bash
echo $AZURE_SP | jq .appId | tr -d '"'
```

Make a note of the result as we will be using it again soon.

```console
2c965760-bb46-4add-94d0-f8e6d2985805
```

</br>

Next, run the following command to retrieve the **password** of the Azure Service Principal.

```bash
echo $AZURE_SP | jq .password | tr -d '"'
```

Make a note of the result as we will be using it again soon.

```console
1e46de92-4c9d-43be-af36-ff26b87e30a3
```

</br>

### Grant the Service Principal Access to the Key Vault Secrets

Next, run the following command to grant the Service Principal **sp-restricted-keyvault-access** *get* access to Secrets in the Key Vault.

```bash
az keyvault set-policy \
--name "iacftvault${RANDOM_ALPHA}" \
--spn "http://sp-restricted-keyvault-access" \
--secret-permissions get \
--output table
```

You should get back a similar response.

```console
Location    Name            ResourceGroup
----------  --------------  --------------------------
westeurope  iacftvault31mr  fine-tune-access-key-vault
```

### Set and retrieve a variable

Now, we will add a password to our AKV, and then retrieve that secret.

Add a secret (like a password) to Key Vault

```bash
az keyvault secret set --vault-name "Contoso-Vault2" --name "ExamplePassword" --value "hVFkk965BuUv"
```

To view the value contained in the secret as plain text:

```bash
az keyvault secret show --name "ExamplePassword" --vault-name "Contoso-Vault2"
```
([back to top](#in-this-article))

## Conclusion

This has been a deep drive into Azure Key Vault. If you've never tried it, try the many code samples we have provided here to get some hands-on practice.

([back to top](#in-this-article))
