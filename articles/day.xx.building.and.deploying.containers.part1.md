# Building and Deploying Containers - Part 1 - Deploy a Container Registry

```text
option 1 - Build GRAV CMS from original Dockerfile
option 3 - turn everything into scripts that are files and not inline. (conversion option)
```

https://github.com/getgrav/docker-grav
https://hub.docker.com/r/evns/grav/
https://docs.microsoft.com/en-us/azure/container-registry/container-registry-get-started-docker-cli

Let's build a Container running Grav from Azure DevOps.

- preface this by creating a Repository in Azure DevOps.
- go over how to create the repository in a Project
- anything else that Is added to this series is added to that repository.
  - This repository/walkthrough has to be quick to add/modify/change.

- Let's go ahead and have this YAML file based Build Pipeline setup to control everything, so that when the YAML file is updated, a build kicks off
  - can show idempotence
  - can show the build and deploy containers scenario

## New Blog Post Series on Azure Containers and Practical YAML Build Pipelines

- create a new Service Principal called **sp-az-build-pipeline-creds**
- go to Project Settings --> Service Connections
  - Create a new Service connection called **sp-az-build-pipeline-creds** and add in the Service Principal Creds.
- create new Repo in your Azure DevOps Project called **az-containers**
- add in the following file **az-containers.yaml**

```yaml
trigger:
- master

pool:
  # Using a Microsoft Hosted Agent - https://docs.microsoft.com/en-us/azure/devops/pipelines/agents/hosted?view=azure-devops
  vmImage: ubuntu-18.04

steps:

# Azure CLI Task - creating the 'containers-in-azure' Resource Group.
- task: AzureCLI@1
  displayName: 'check-resource-group'
  inputs:
    # Using Service Principal, 'sp-az-build-pipeline-creds', to authenticate to the Subscription.
    azureSubscription: 'sp-az-build-pipeline-creds'
    scriptLocation: inlineScript
    inlineScript: |
     az group create \
     --name containers-in-azure \
     --location westeurope
```

- Write About each step in this YAML File about what is going on and continue from there and how we will continue to build on it in subsequent blog posts.
- follow up blog post will be about:
- adding in the Azure Container Registry
- adding in Dockerfile for Container
- customizing the Dockerfile for the Container
- Container Deployment (Grav CMS)
- Modifying the Grav CMS Container
- Modifying the YAML Build File to first delete and redeploy the Container



```bash
az group create \
--name containers-in-azure \
--location westeurope
```

You should get back the following output:

```console
{
  "id": "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/containers-in-azure",
  "location": "westeurope",
  "managedBy": null,
  "name": "containers-in-azure",
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

> **NOTE:** We are appending this to the name of our Container Registry to ensure we create a unique name.

<br />

```bash
az acr create \
--resource-group containers-in-azure \
--name "containerreg${RANDOM_ALPHA}" \
--sku Basic
```
