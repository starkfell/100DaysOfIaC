# Day 40 - Practical Guide for YAML Build Pipelines in Azure DevOps - Part 4

*The other posts in this Series can be found below.*

***[Day 35 - Practical Guide for YAML Build Pipelines in Azure DevOps - Part 1](./day.35.building.a.practical.yaml.pipeline.part.1.md)***</br>
***[Day 38 - Practical Guide for YAML Build Pipelines in Azure DevOps - Part 2](./day.38.building.a.practical.yaml.pipeline.part.2.md)***</br>
***[Day 39 - Practical Guide for YAML Build Pipelines in Azure DevOps - Part 3](./day.39.building.a.practical.yaml.pipeline.part.3.md)***</br>
***[Day 40 - Practical Guide for YAML Build Pipelines in Azure DevOps - Part 4](./day.40.building.a.practical.yaml.pipeline.part.4.md)***</br>

</br>

Today, we are going to refactor our Azure Build Pipeline into a single Script with more readable output and a Single Azure CLI Task.

## Transform the existing tasks into a Bash Script

Create a new file in your **practical-yaml-build-pipe** repository called **base-infra.sh**.

Next, copy and paste the code below into it and commit it to the repository.

```bash
#!/bin/bash

az group create \
--name practical-yaml \
--location westeurope

az acr create \
--name pracazconreg \
--resource-group practical-yaml \
--sku Basic

az acr login \
--name pracazconreg \
--output table
```

</br>

While the script above will technically work when called in Azure CLI Task, there is no context as to where the script is supposed to run from or why it's performing it's specific actions. Update the script above with the following comments as shown below.

```bash
#!/bin/bash

# Author:      Ryan Irujo
# Name:        base-infra.sh
# Description: This script deploys Infrastructure into a target Azure Subscription from an Azure CLI Task in Azure DevOps.

# Deploying the 'practical-yaml' Resource Group.
az group create \
--name practical-yaml \
--location westeurope

# Deploying the 'pracazconreg' Azure Container Registry.
az acr create \
--name pracazconreg \
--resource-group practical-yaml \
--sku Basic

# Logging into the 'pracazconreg' Azure Container Registry.
az acr login \
--name pracazconreg \
--output table
```

</br>

Now that we can identify the purpose of this script, we can update the output of the script to be more readable in the Logs task. Replace the existing content of the **base-infra.sh** script with the code below.

```bash
#!/bin/bash

# Author:      Ryan Irujo
# Name:        base-infra.sh
# Description: This script deploys Infrastructure into a target Azure Subscription from an Azure CLI Task in Azure DevOps.

# Deploying the 'practical-yaml' Resource Group.
az group create \
--name practical-yaml \
--location westeurope \
--output none && echo "[---info---] Resource Group: practical-yaml was created successfully or already exists."

# Deploying the 'pracazconreg' Azure Container Registry.
az acr create \
--name pracazconreg \
--resource-group practical-yaml \
--sku Basic && echo "[---info---] Azure Container Registry: pracazconreg was created successfully or already exists."

# Logging into the 'pracazconreg' Azure Container Registry.
az acr login \
--name pracazconreg \
--output none && echo "[---info---] Logged into Azure Container Registry: pracazconreg."
```

</br>

## Update the YAML Configuration for the Build Pipeline

Next, edit the **idempotent-pipe.yaml** in the **practical-yaml-build-pipe** repository; copy and paste the code below into it.

```yaml
# Builds are automatically triggered from the master branch in the 'practical-yaml-build-pipe' Repo.
trigger:
- master

pool:
  # Using a Microsoft Hosted Agent - https://docs.microsoft.com/en-us/azure/devops/pipelines/agents/hosted?view=azure-devops
  vmImage: ubuntu-18.04

steps:

# Azure CLI Task - Deploying Base Infrastructure.
- task: AzureCLI@1
  displayName: 'Deploying Base Infrastructure'
  inputs:
    # Using Service Principal, 'sp-az-build-pipeline', to authenticate to the Azure Subscription.
    azureSubscription: 'sp-az-build-pipeline'
    scriptLocation: inlineScript
    inlineScript: |
     env
```

**In this article:**

[Grant the Service Principal Ownership of the Resource Group](#grant-the-service-principal-ownership-of-the-resource-group)</br>
[Add in task for Deploying an Azure Container Registry](#add-in-task-for-deploying-an-azure-container-registry)</br>
[Add in task for Logging in to the Azure Container Registry](#add-in-task-for-logging-in-to-the-azure-container-registry)</br>
[Things to Consider](#things-to-consider)</br>
[Conclusion](#conclusion)</br>

## Grant the Service Principal Ownership of the Resource Group

```text
option 1 - Build GRAV CMS from original Dockerfile
option 2 - cleanup existing scripts for better readability of output in task logs
option 3 - turn everything into scripts that are files and not inline. (conversion option)
```
