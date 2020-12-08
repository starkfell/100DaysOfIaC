# YAML Pipelines – Up and Running in an Hour

- [YAML Pipelines – Up and Running in an Hour](#yaml-pipelines--up-and-running-in-an-hour)
  - [Prerequisites](#prerequisites)
  - [Setup a Service Connection to your Azure Subscription](#setup-a-service-connection-to-your-azure-subscription)
  - [Create a new Repository](#create-a-new-repository)
  - [Create a YAML Build Pipeline File](#create-a-yaml-build-pipeline-file)
  - [Azure DevOps Agents - Microsoft vs. Self-Hosted](#azure-devops-agents---microsoft-vs-self-hosted)
  - [Create an Azure DevOps Pipeline](#create-an-azure-devops-pipeline)
  - [Add an additional task to the YAML Build Pipeline File](#add-an-additional-task-to-the-yaml-build-pipeline-file)
  - [Using a Parameter in a Build Pipeline](#using-a-parameter-in-a-build-pipeline)
  - [Using multiple parameters in a Build Pipeline](#using-multiple-parameters-in-a-build-pipeline)
  - [Deploying resources dynamically in a Build Pipeline](#deploying-resources-dynamically-in-a-build-pipeline)
  - [Additional Notes](#additional-notes)

<br/>

## Prerequisites

You will need access to an Azure Subscription and Administrator Access to your own Azure DevOps Project to perform this demo.

<br/>

## Setup a Service Connection to your Azure Subscription

Open up your **yaml-pipelines-demo** Project

Project Settings --> Pipelines --> Service connections --> Create Service Connection.

Select Azure Resource Manager

Service Principal (automatic)

Service connection name is **yaml-pipelines-demo**. Leave **Grant access permission to all pipelines** under **Secuirty** checked. Lastly, click **Save**.

> **Note:** When removing this automated Service Principal later for your Azure Subscription, it's going to have a name similar to what is shown below:

```text
Syntax: {AZURE_DEVOPS_ORG_NAME}-{AZURE_DEVOPS_PROJECT_NAME}-{GUID}

Example: ryanirujo0298-yaml-pipelines-demo-84f065f5-e37a-4127-9c82-0b1ecd57a652
```

<br/>

## Create a new Repository

In the **yaml-pipelines-demo** Project, click on **Project Settings** and go to **Repos** and then **Repositories**, click on **Create**.

Name the Repository **pipeline-demo**, leave the rest of the default values and then click on **Create**.

<br/>

## Create a YAML Build Pipeline File

Browse to the **yaml-pipelines-demo** Project, click on **Repos**. Click on the **three dots** next to **pipeline-demo** and then click **New** and **File**.

Name the file **pipeline.yaml** and click **Create**.

Paste in the contents below and then click **Commit**.

```yaml
# Build is automatically triggered from the [main] branch in the Repo.
trigger:
- main

# Using an Azure DevOps Linux Agent.
pool:
  vmImage: ubuntu-latest

# Adding Azure Resources using Azure CLI.
steps:
- task: AzureCLI@2
  displayName: 'Deploying a Resource Group'
  inputs:
    azureSubscription: 'yaml-pipelines-demo'
    scriptType: 'bash'
    scriptLocation: 'inlineScript'
    'inlineScript': |
       az group create --name yaml-pipeline-demo-rg --location westeurope --output table
```

<br/>

## Azure DevOps Agents - Microsoft vs. Self-Hosted

Additional documentation can be found below.

[Microsoft-hosted Agents](https://docs.microsoft.com/en-us/azure/devops/pipelines/agents/hosted?view=azure-devops&tabs=yaml)

[Self-hosted Linux Agents](https://docs.microsoft.com/en-us/azure/devops/pipelines/agents/v2-linux?view=azure-devops)

[Self-hosted Windows Agents](https://docs.microsoft.com/en-us/azure/devops/pipelines/agents/v2-windows?view=azure-devops)

<br/>

## Create an Azure DevOps Pipeline

Browse to the **yaml-pipelines-demo** Project, click on **Pipelines** and then **Create Pipeline**.

Click on **Azure Repos Git**.

Click on **pipeline-demo**.

Click on **Existing Azure Pipelines YAML file**.

Leave Branch set to **main** and click on the drop-down for **Path** and select **pipeline.yaml**.

Next, click **Continue**.

Next, click on **Run**.

Check in Azure DevOps and the Azure Portal to verify that Resource Group **yaml-pipeline-demo-rg** was deployed.

<br/>

## Add an additional task to the YAML Build Pipeline File

In the **yaml-pipelines-demo** Project, edit the **pipeline.yaml** file.

Copy the contents below over the existing contents of the **pipeline.yaml** file and then **Commit** it.

```yaml
# Build is automatically triggered from the [main] branch in the Repo.
trigger:
- main

# Using an Azure DevOps Linux Agent.
pool:
  vmImage: ubuntu-latest

# Adding Azure Resources using Azure CLI.
steps:
- task: AzureCLI@2
  displayName: 'Deploy Resource Group'
  inputs:
    azureSubscription: 'yaml-pipelines-demo'
    scriptType: 'bash'
    scriptLocation: 'inlineScript'
    'inlineScript': |
       az group create --name yaml-pipeline-demo-rg --location westeurope --output table

- task: AzureCLI@2
  displayName: 'Deploy Storage Account'
  inputs:
    azureSubscription: 'yaml-pipelines-demo'
    scriptType: 'bash'
    scriptLocation: 'inlineScript'
    'inlineScript': |
       az storage account create --name yamlpipedemostr --resource-group yaml-pipeline-demo-rg --location westeurope --output table
```

<br/>

Check in Azure DevOps and the Azure Portal to verify the Storage account was deployed to Resource Group **yaml-pipeline-demo-rg** was deployed.

<br/>

Why you shouldn't use Azure PowerShell. The first time you deploy an Azure Resource with Azure PowerShell, it will succeed; subsequent runs will return errors to the Pipeline.

```log
New-AzStorageAccount: /home/vsts/work/_temp/542269f5-8682-4a5d-a10a-4e77aa63517f.ps1:3
Line |
   3 |  New-AzStorageAccount -ResourceGroupName yaml-pipeline-demo-rg -Name y …
     |  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
     | The storage account named yamlpipedemostr is already taken.
     | (Parameter 'Name')

##[error]PowerShell exited with code '1'.
Finishing: Deploy Storage Account

```

<br/>

## Using a Parameter in a Build Pipeline

In the **yaml-pipelines-demo** Project, edit the **pipeline.yaml** file.

Copy the contents below over the existing contents of the **pipeline.yaml** file and then **Commit** it.

```yaml
# Build is automatically triggered from the [main] branch in the Repo.
trigger:
- main

# Using an Azure DevOps Linux Agent.
pool:
  vmImage: ubuntu-latest

# Parameters.
parameters:
- name: azureSubscription
  default: yaml-pipelines-demo

# Adding Azure Resources using Azure CLI.
steps:
- task: AzureCLI@2
  displayName: 'Deploy Resource Group'
  inputs:
    azureSubscription: "${{ parameters.azureSubscription }}"
    scriptType: 'bash'
    scriptLocation: 'inlineScript'
    'inlineScript': |
       az group create --name yaml-pipeline-demo-rg --location westeurope --output table

- task: AzureCLI@2
  displayName: 'Deploy Storage Account'
  inputs:
    azureSubscription: "${{ parameters.azureSubscription }}"
    scriptType: 'bash'
    scriptLocation: 'inlineScript'
    'inlineScript': |
       az storage account create --name yamlpipedemostr --resource-group yaml-pipeline-demo-rg --location westeurope --output table
```

<br/>

Check in Azure DevOps and the Azure Portal to verify the resources were deployed successfully.

<br/>

## Using multiple parameters in a Build Pipeline

In the **yaml-pipelines-demo** Project, edit the **pipeline.yaml** file.

Copy the contents below over the existing contents of the **pipeline.yaml** file and then **Commit** it.

```yaml
# Build is automatically triggered from the [main] branch in the Repo.
trigger:
- main

# Using an Azure DevOps Linux Agent.
pool:
  vmImage: ubuntu-latest

# Parameters.
parameters:
- name: azSub
  default: yaml-pipelines-demo
- name: rgName
  default: yaml-pipeline-demo-rg
- name: azLoc
  default: westeurope
- name: strName
  default: yamlpipedemostr

# Adding Azure Resources using Azure CLI.
steps:
- task: AzureCLI@2
  displayName: 'Deploy Resource Group'
  inputs:
    azureSubscription: "${{ parameters.azSub }}"
    scriptType: 'bash'
    scriptLocation: 'inlineScript'
    'inlineScript': |
       az group create --name "${{ parameters.rgName }}" --location "${{ parameters.azLoc }}" --output table

- task: AzureCLI@2
  displayName: 'Deploy Storage Account'
  inputs:
    azureSubscription: "${{ parameters.azSub }}"
    scriptType: 'bash'
    scriptLocation: 'inlineScript'
    'inlineScript': |
       az storage account create --name "${{ parameters.strName }}" --resource-group "${{ parameters.rgName }}" --location "${{ parameters.azLoc }}" --output table
```

<br/>

Check in Azure DevOps and the Azure Portal to verify the resources were deployed successfully.

<br/>

## Deploying resources dynamically in a Build Pipeline

In the **yaml-pipelines-demo** Project, copy the contents below into a file called **deploy-resources.yaml** file and then **Commit** it.

```yaml
# Deployment of Azure Resources from a Template.
jobs:
  - job: deploy_resources
    displayName: 'Deploy Resources to [${{ parameters.env }}]'
    steps:

    # Creating Resource Groups.
    - ${{ each rgName in parameters.rgNames }}:
      - task: AzureCLI@2
        displayName: 'Create RG [${{ rgName }}]'
        inputs:
          azureSubscription: "${{ parameters.azSub }}"
          scriptType: 'bash'
          scriptLocation: 'inlineScript'
          'inlineScript': |
             az group create --name ${{ rgName }} --location ${{ parameters.azLoc }} --output table

    # Creating Storage Accounts.
    - ${{ each rgName in parameters.rgNames }}:
      - task: AzureCLI@2
        displayName: 'Deploy Storage to [${{ rgName }}]'
        inputs:
          azureSubscription: "${{ parameters.azSub }}"
          scriptType: 'bash'
          scriptLocation: 'inlineScript'
          'inlineScript': |
             storageAccountName=$(echo "${{ rgName }}" | tr -d '-' | sed 's/rg/str/g')
             az storage account create --name "$storageAccountName" --resource-group "${{ rgName }}" --location "${{ parameters.azLoc }}" --output table
```

<br/>

Next, Copy the contents below over the existing contents of the **pipeline.yaml** file and then **Commit** it.

```yaml
# Build is automatically triggered from the [main] branch in the Repo.
trigger:
- main

# Using an Azure DevOps Linux Agent.
pool:
  vmImage: ubuntu-latest

stages:

# Passing parameters to the template.
- stage: deploy_resources
  jobs:
  - template: deploy-resources.yaml
    parameters:
      rgNames: ["yaml-pipeline-demo-rg","yaml-pipeline-dev-rg","yaml-pipeline-test-rg","yaml-pipeline-prod-rg"]
      azSub: yaml-pipelines-demo
      azLoc: westeurope
      env: demo
```

<br/>

Check in Azure DevOps and the Azure Portal to verify that the four Resource Groups and four Storage Accounts were deployed successfully.

<br/>

## Additional Notes

[Azure DevOps - Runtime Parameters](https://docs.microsoft.com/en-us/azure/devops/pipelines/process/runtime-parameters?view=azure-devops&tabs=script)

<br/>
