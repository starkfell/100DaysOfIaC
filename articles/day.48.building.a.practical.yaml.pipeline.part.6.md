# Day 48 - Practical Guide for YAML Build Pipelines in Azure DevOps - Part 6

*The other posts in this Series can be found below.*

***[Day 35 - Practical Guide for YAML Build Pipelines in Azure DevOps - Part 1](./day.35.building.a.practical.yaml.pipeline.part.1.md)***</br>
***[Day 38 - Practical Guide for YAML Build Pipelines in Azure DevOps - Part 2](./day.38.building.a.practical.yaml.pipeline.part.2.md)***</br>
***[Day 39 - Practical Guide for YAML Build Pipelines in Azure DevOps - Part 3](./day.39.building.a.practical.yaml.pipeline.part.3.md)***</br>
***[Day 40 - Practical Guide for YAML Build Pipelines in Azure DevOps - Part 4](./day.40.building.a.practical.yaml.pipeline.part.4.md)***</br>
***[Day 41 - Practical Guide for YAML Build Pipelines in Azure DevOps - Part 5](./day.40.building.a.practical.yaml.pipeline.part.5.md)***</br>

</br>

Today, we are going to further refine the **base-infra.sh** bash script..

**In this article:**

[Adding Error Handling for ACR Creation and Login]
[Separating the Login command in a Separate Script]


[Things to Consider](#things-to-consider)</br>
[Conclusion](#conclusion)</br>

## Adding Error Handling for ACR Creation and Login

In Part 5, we added Error Handling to the Resource Group creation from the **az group create** command. We are going to add the same type of error handling now to **az acr create** and **az acr login**.

At the end of Part 5, our **bas-infra.sh** script was the same as what is shown below.

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

<br/>

Below is the same **base-infra.sh** script with error handling added for the **az acr create** command.

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

# Deploying the 'pracazconreg' Azure Container Registry.
CHECK_ACR=$(az acr create \
--name pracazconreg \
--resource-group practical-yaml \
--sku Basic \
--query provisioningState \
--output tsv)

if [ "$CHECK_ACR" == "Succeeded" ]; then
    echo "[---success---] Azure Container Registry 'pracazconreg' was deployed successfully. Provisioning State: $CHECK_ACR."
else
    echo "[---fail------] Azure Container Registry 'pracazconreg' was not deployed successfully. Provisioning State: $CHECK_ACR."
    exit 2
fi

```

</br>

On your Linux Host (with Azure CLI installed), open up a bash prompt and run the following command.

```bash
az acr create \
--name pracazconreg \
--resource-group practical-yaml \
--sku Basic
```

You should get the following output since the **pracazconreg** Azure Container Registry is already in place.

```json
{
  "adminUserEnabled": false,
  "creationDate": "2019-11-09T13:38:45.459627+00:00",
  "id": "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/practical-yaml/providers/Microsoft.ContainerRegistry/registries/pracazconreg",
  "location": "westeurope",
  "loginServer": "pracazconreg.azurecr.io",
  "name": "pracazconreg",
  "networkRuleSet": null,
  "policies": {
    "quarantinePolicy": {
      "status": "disabled"
    },
    "retentionPolicy": {
      "days": 7,
      "lastUpdatedTime": "2019-11-09T13:40:46.896754+00:00",
      "status": "disabled"
    },
    "trustPolicy": {
      "status": "disabled",
      "type": "Notary"
    }
  },
  "provisioningState": "Succeeded",
  "resourceGroup": "practical-yaml",
  "sku": {
    "name": "Basic",
    "tier": "Basic"
  },
  "status": null,
  "storageAccount": null,
  "tags": {},
  "type": "Microsoft.ContainerRegistry/registries"
}
```

</br>

So unlike the check made for the Resource Group where the **provisioningState** was under the **properties** section. For the Azure Container Registry, the **provisioningState** is in the root section of the JSON output; this is why it's query is slightly different than the query created for the Resource Group. So bear this in mind going forward.

*When querying Resources in Azure, make sure to test the JSON Output thoroughly when creating your error handling!*

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

</br>

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

</br>

Since the default output of this command is in JSON and provides us with a **provisioningState** value of the operation, we have multiple options to use for querying it:

* **[jq](https://stedolan.github.io/jq/)**, a lightweight and flexible command-line JSON processor
* The Azure CLI **[--query](https://docs.microsoft.com/bs-cyrl-ba/cli/azure/query-azure-cli?view=azure-cli-latest)** argument

Since the **--query** argument is already native to the Azure CLI, it's in our best interest to make use of it.

</br>

Run the following command below.

```bash
CHECK_RG=$(az group create \
--name practical-yaml \
--location westeurope \
--query properties.provisioningState \
--output tsv)
```

</br>

Run the following command to get see the results in the **$CHECK_RG** variable.

```bash
echo $CHECK_RG
```

You should get back the following response.

```console
Succeeded
```

</br>

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

</br>

So we've added the **--output** argument and set it to **tsv** (tab-separated value) here to ensure that the result of the **properties.provisioningState** isn't surrounded by quotes making it easier for us to analyze returned value using the bash *string comparison operator*, (**==**).

</br>

## Update the Bash Script

Next, in VS Code, open the **base-infra.sh** file. Replace it's current contents with the code below and save and commit it to the repository.

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

</br>

## Check on the Build Pipeline Job

Review the logs of the most current job in the **practical-yaml-build-pipe** Build Pipeline and you should see the following output from the **Deploying Base Infrastructure** Azure CLI Task.

![001](../images/day41/day.41.building.a.practical.yaml.pipeline.part.5.001.png)

</br>

> **NOTE:** We're going to do the same thing for the Azure Container Registry and it's related Login in the next blog post of our *Practical Guide for YAML Build Pipelines* so you won't be missing any code in the end.

</br>

## Things to Consider

Irrespective of what tools you are using, be aware of any updates that are being made to the toolset; for example, going from Azure CLI 2.0.69 to Azure CLI 2.0.70. This is where having multiple environments for CI/CD deployment becomes very valuable. If you are using the exact same code for each environment and you have an update to your toolset, any odd behavior or breaking changes in Development will appear before deploying into Production. Sticking with toolsets that are not cloud-based is not necessarily a better idea. If someone else is updating your infrastructure, they only have to accidentally make one incorrect update to potentially throw everything out of whack for your deployments.

The Resource Group we are dealing with already exists so the error handling we've created will absolutely work, make sure you test your error handling when the resources you are trying to deploy don't exist yet or are in a state they aren't supposed to be in. This will ensure that you haven't forgotten anything and covered as much as you can.

Any error handling that you create needs to be thoroughly tested before running it in Production.

Consider using do/while loops for commands or processes that run for an indefinite length of time; this would allow you to check for the state you are looking for when it occurs.

</br>

## Conclusion

In today's article we further refined the **base-infra.sh** bash script and demonstrated the process of adding in your own error handling. If there's a specific scenario that you wish to be covered in future articles, please create a **[New Issue](https://github.com/starkfell/100DaysOfIaC/issues)** in the [starkfell/100DaysOfIaC](https://github.com/starkfell/100DaysOfIaC/) GitHub repository.
