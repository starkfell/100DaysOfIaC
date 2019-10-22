# Building and Deploying Containers - Part 1 - Deploy a Container Registry

Let's build a Container running Grav from Azure DevOps.

- preface this by creating a Repository in Azure DevOps.
- go over how to create the repository in a Project
- anything else that Is added to this series is added to that repository.
  - This repository/walkthrough has to be quick to add/modify/change.

- Let's go ahead and have this YAML file based Build Pipeline setup to control everything, so that when the YAML file is updated, a build kicks off
  - can show idempotence
  - can show the build and deploy containers scenario

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
