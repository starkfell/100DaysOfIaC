# Day 98 - Using Resource Locks in a YAML Pipeline




## Azure Build Pipeline

Follow the instructions in [Day 35](./day.35.building.a.practical.yaml.pipeline.part.1.md) for creating a Service Principal for the Build Pipeline and adding creating the Service Connection for it in Azure DevOps if you haven't already created the **sp-az-build-pipeline** Service Principal.

Next, in VS Code, replace the current contents of the **lock-pipe.yaml** file with what is shown below. Afterwards, save and commit your changes to the repository.

```yaml
# Builds are automatically triggered from the master branch in the 'practical-yaml-build-pipe' Repo.
trigger:
- master

pool:
  # Using a Microsoft Hosted Agent - https://docs.microsoft.com/en-us/azure/devops/pipelines/agents/hosted?view=azure-devops
  vmImage: ubuntu-18.04

steps:

# Azure CLI Task - Unlock Azure Resources.
- task: AzureCLI@2
  displayName: 'Unlock Azure Resources'
  inputs:
    # Using Service Principal, 'sp-az-build-pipeline', to authenticate to the Azure Subscription.
    azureSubscription: 'sp-az-build-pipeline'
    scriptType: 'bash'
    scriptLocation: 'scriptPath'
    scriptPath: './unlock-azure-resources.sh'

# Azure CLI Task - Delete Azure Resources with Tag 'SetForRemoval'.
- task: AzureCLI@2
  displayName: 'Build and Push NGINX Docker Image to ACR'
  inputs:
    # Using Service Principal, 'sp-az-build-pipeline', to authenticate to the Azure Subscription.
    azureSubscription: 'sp-az-build-pipeline'
    scriptType: 'bash'
    scriptLocation: 'scriptPath'
    scriptPath: './delete-azure-resources.sh'

# Azure CLI Task - Relock Azure Resources.
- task: AzureCLI@2
  displayName: 'Relock Azure Resources'
  inputs:
    # Using Service Principal, 'sp-az-build-pipeline', to authenticate to the Azure Subscription.
    azureSubscription: 'sp-az-build-pipeline'
    scriptType: 'bash'
    scriptLocation: 'scriptPath'
    scriptPath: './relock-azure-resourcese.sh'
```
