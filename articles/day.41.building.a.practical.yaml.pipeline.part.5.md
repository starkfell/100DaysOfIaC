# Day 41 - Practical Guide for YAML Build Pipelines in Azure DevOps - Part 5

*The other posts in this Series can be found below.*

***[Day 35 - Practical Guide for YAML Build Pipelines in Azure DevOps - Part 1](./day.35.building.a.practical.yaml.pipeline.part.1.md)***</br>
***[Day 38 - Practical Guide for YAML Build Pipelines in Azure DevOps - Part 2](./day.38.building.a.practical.yaml.pipeline.part.2.md)***</br>
***[Day 39 - Practical Guide for YAML Build Pipelines in Azure DevOps - Part 3](./day.39.building.a.practical.yaml.pipeline.part.3.md)***</br>
***[Day 40 - Practical Guide for YAML Build Pipelines in Azure DevOps - Part 4](./day.40.building.a.practical.yaml.pipeline.part.4.md)***</br>
***[Day 41 - Practical Guide for YAML Build Pipelines in Azure DevOps - Part 5](./day.40.building.a.practical.yaml.pipeline.part.5.md)***</br>

</br>

next

Today, we are going to further refine the **base-infra.sh** bash script.

</br>

## Code Review

While Azure CLI commands are idempotent, there's the possibility that you come across a command that doesn't behave identically to the others. Because of this, you need to understand how you can capture their output, parse the output, and make decisions based on the parsed results.

</br>

Let's start off by looking at the current state of the **base-infra.sh** script which should match what is shown below.

```bash
#!/bin/bash

# Author:      Ryan Irujo
# Name:        base-infra.sh
# Description: Deploys Infrastructure to a target Azure Sub from an Azure CLI Task in Azure DevOps.

# Deploying the 'practical-yaml' Resource Group.
az group create \
--name practical-yaml \
--location westeurope \
--output none && echo "[---info---] Resource Group: practical-yaml was created successfully or already exists."

# Deploying the 'pracazconreg' Azure Container Registry.
az acr create \
--name pracazconreg \
--resource-group practical-yaml \
--sku Basic \
--output none && echo "[---info---] Azure Container Registry: pracazconreg was created successfully or already exists."

# Logging into the 'pracazconreg' Azure Container Registry.
az acr login \
--name pracazconreg \
--output none && echo "[---info---] Logged into Azure Container Registry: pracazconreg."
```

</br>

So to start, we have real error handling other than if the command succeeds then we get a line **echoed** out telling us it succeeded. In it's current state, we aren't checking for failures or have anything in place in case there is an actual failure.

To start with, let's take the **az group create** command and capture all of its output into a variable. With the output stored in a variable, we can parse it and make our own logic to determine whether the command was successful or not.

</br>

On your Linux Host (with Azure CLI installed), open up a bash prompt and run the following command.

```bash
az group create \
--name practical-yaml \
--location westeurope
```

You should get the following output since the **practical-yaml** Resource Group is already in place.

```console
{
  "id": "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/practical-yaml",
  "location": "westeurope",
  "managedBy": null,
  "name": "practical-yaml",
  "properties": {
    "provisioningState": "Succeeded"
  },
  "tags": null,
  "type": "Microsoft.Resources/resourceGroups"
}
```

Since the default output of this command is in JSON and provides us with a **provisioningState** value of the operation, we have multiple options to use for querying it:

* **[jq](https://stedolan.github.io/jq/)**, a lightweight and flexible command-line JSON processor
* The Azure CLI **[--query](https://docs.microsoft.com/bs-cyrl-ba/cli/azure/query-azure-cli?view=azure-cli-latest)** argument

Since the **--query** argument is already native to the Azure CLI, it's in our best interest to make use of it.

Run the following command below:

```bash
CHECK_RG=$(az group create \
--name practical-yaml \
--location westeurope \
--query properties.provisioningState \
--output tsv)
```

Run the following command to get see the results in the **$CHECK_RG** variable.

```bash
echo $CHECK_RG
```

You should get back the following response.

```console
Succeeded
```

Now that we know the value of **provisioningState** to look for when the Resource Group has been deployed (or exists), we can build some error handling around this process. Below is the error handling I've added to the **az group create** command.

```bash
CHECK_RG=$(az group create \
--name practical-yaml \
--location westeurope \
--query properties.provisioningState \
--output tsv)

if [ "$CHECK_RG" == "Succeeded" ]; then
    echo "[---success---] Resource Group 'practical-yaml' was deployed successfully. Provisioning State: $CHECK_RG."
else
    echo "[---fail------] Resource Group 'practical-yaml' was not deployed successfully. Provisioning State: $CHECK_RG."
    exit 2
fi
```

So we've added the **--output** argument and set it to **tsv** (tab-separated value) here to ensure that the result of the **properties.provisioningState** isn't surrounded by quotes making it easier for us to analyze returned value using the bash *string comparison operator*, **==**.

Next, in VS Code, open the **base-infra.sh** file. Replace it's current contents with the code below.

```bash
#!/bin/bash

# Author:      Ryan Irujo
# Name:        base-infra.sh
# Description: Deploys Infrastructure to a target Azure Sub from an Azure CLI Task in Azure DevOps.

# Deploying the 'practical-yaml' Resource Group.
CHECK_RG=$(az group create \
--name practical-yaml \
--location westeurope \
--query properties.provisioningState \
--output tsv)

if [ "$CHECK_RG" == "Succeeded" ]; then
    echo "[---success---] Resource Group 'practical-yaml' was deployed successfully. Provisioning State: $CHECK_RG."
else
    echo "[---fail------] Resource Group 'practical-yaml' was not deployed successfully. Provisioning State: $CHECK_RG."
    exit 2
fi
```

> **NOTE:** Don't worry, we're going to do the same thing for the Azure Container Registry and it's related Login in the next blog post so you won't be missing any code in the end.


```text
option 1 - Build GRAV CMS from original Dockerfile
option 2 - cleanup existing scripts for better readability of output in task logs
option 3 - turn everything into scripts that are files and not inline. (conversion option)
```
