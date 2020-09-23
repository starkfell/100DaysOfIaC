# Day 101 - Deploying an AKS Cluster FAST from Azure Cloud Shell

Welcome to the first installment of "100 MORE Days of Infrastructure-as-Code in Azure"! In today's article we will be covering how to deploy an AKS Cluster from Azure Cloud Shell, but with a new facet - Youtube video! The code and related artifacts for each new installment will be here with a link to the video on our YouTube channel.

Today, we're covering quick and effective AKS cluster deployment with Azure Cloud Shell. While our demonstration is not recommended for a Production Environment, we hope it will a way to quickly deploy and AKS cluster for study and exam prep! Additionally, we have opted to use a walkthrough video instead of an article. In order to make things as easy as possible, all commands in the video are able to be copy and pasted from the **[Video Walkthrough Commands](#video-walkthrough-commands)** section.

Find the code and reference links below!

</br>


## Video Walkthrough (YouTube)

**TO VIEW:** Click **[HERE](https://youtu.be/T3GQ4FyTu-Y)** to view the walkthrough video on Youtube at https://youtu.be/T3GQ4FyTu-Y!

**TO SUBSCRIBE:** Click **[HERE](https://www.youtube.com/channel/UCAr0yk0um7lwLjmrKfzwyig?sub_confirmation=1)** to follow us on Youtube so you get a heads up on future videos!

</br>

> **NOTE:** All content for this article was tested and written for use with Azure Cloud Shell.

</br>

## Video Walkthrough Commands (aka "the code")

All commands used in video are in the document below.

```bash
# Enabling the aks-preview Extension so we can use the [--node-resource-group] parameter.
az extension add \
--name aks-preview

# (Optional) Retrieving the Azure Active Directory Tenant ID.
AAD_TENENT_ID=$(az account show --query tenantId --output tsv)

# Generating a Random Number to give our AKS Cluster a unique name. (At least good enough for this demo)
RAND=$(shuf -i 1-9999 -n 1)

# Creating the Azure Resource Group for the AKS Service.
az group create \
--name "aks-iam-${RAND}" \
--location "westeurope"

# Deploying our AKS Cluster.
az aks create \
--name "aks-iam-${RAND}" \
--dns-name-prefix "aks-iam-${RAND}" \
--node-resource-group "aks-iam-${RAND}-nodes" \
--resource-group "aks-iam-${RAND}" \
--location "westeurope" \
--generate-ssh-keys \
--enable-cluster-autoscaler \
--enable-aad \
--aad-tenant-id "${AAD_TENENT_ID}" \
--admin-username "lxadmin" \
--nodepool-name "primarypool" \
--kubernetes-version "1.18.8" \
--node-count "2" \
--min-count "1" \
--max-count "2" \
--node-osdisk-size "100" \
--node-vm-size "Standard_DS2_v2"

# Retrieving the [admin] credentials as a [kubeconfig] file to use to login to the AKS Cluster.
az aks get-credentials \
--name "aks-iam-${RAND}" \
--resource-group "aks-iam-${RAND}" \
--file "aks-iam-${RAND}-admin-kubeconfig" \
--admin

# Setting the [kubectl] command to point at our [kubeconfig] file.
export KUBECONFIG=./aks-iam-${RAND}-admin-kubeconfig

# Retrieving information about the AKS Cluster.
kubectl cluster-info

# Listing the Worker Nodes on the AKS Cluster.
kubectl get nodes

# Removing the AKS Cluster.
az aks cluster delete \
--name "aks-iam-${RAND}" \
--resource-group "aks-iam-${RAND}"

# Removing the [kubeconfig] file from our Azure Cloud Shell session.
rm -rf ./aks-iam-${RAND}-admin-kubeconfig

# Removing the AKS Service Principal Information from our Azure Cloud Shell session.
rm -rf .azure/aksServicePrincipal.json
```

</br>

## Resource Links

AKS-Engine on Github
https://github.com/Azure/aks-engine

Quickstart for Bash in Azure Cloud Shell
https://docs.microsoft.com/en-us/azure/cloud-shell/quickstart

Enable Azure Monitor for Containers
https://docs.microsoft.com/en-us/azure/azure-monitor/insights/container-insights-onboard

</br>

## Conclusion

We're REALLY excited to continue this series! If there's a specific scenario that you wish to be covered in future articles, please create a **[New Issue](https://github.com/starkfell/100DaysOfIaC/issues)** in the [starkfell/100DaysOfIaC](https://github.com/starkfell/100DaysOfIaC/) GitHub repository.
