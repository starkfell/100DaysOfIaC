# Day 101 - Deploying an AKS Cluster from Azure Cloud Shell as fast as possible

In today's article we will be covering how to deploy an AKS Cluster from Azure Cloud Shell. While our demonstration is not recommended for a Production Environment, we hope it will push you in the right direction for learning how to use AKS! Additionally, we have opted to use a walkthrough video instead of an article. In order to make things as easy as possible, all commands in the video are able to be copy and pasted from the **[Video Walkthrough Commands](#video-walkthrough-commands)** section.

</br>

Click **[here](https://here.local.placeholder)** to view the walkthrough.

</br>

> **NOTE:** All content for this article was tested and written for use with Azure Cloud Shell.

</br>

## Video Walkthrough Commands

All commands used in video are in the document below.

```bash
# Enabling the aks-preview Extension so we can use the [--node-resource-group] parameter.
az extension add \
--name aks-preview

# (Optional) Retrieving the Azure Active Directory Tenant ID.
AAD_TENENT_ID=$(az account show --query tenantId --output tsv)

# Generating a Random Number to give our AKS Cluster a unique name. (At least good enough for this demo)
RAND=$(shuf -i 1-9999 -n 1)

# Creating the Auzre Resource Group for the AKS Service.
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

# Retrieving informatino about the AKS Cluster.
kubectl cluster-info

# Listing the Worker Nodes on the AKS Cluster.
kubectl get nodes

# Removing the AKS Cluster.
az aks cluster delete \
--name "aks-iam-${RAND}" \
--resource-group "aks-iam-${RAND}"

# Removing the [kubeconfig] file from our Azure Cloud Shell session.
rm -rf ./aks-iam-${RAND}-admin-kubeconfig

# Removing the AKS Service Principal Inforamtion from our Azure Cloud Shell session.
rm -rf .azure/aksServicePrincipal.json
```

</br>

## Things to Consider

Plenty of Things to Consider...

</br>

## Conclusion

In today's article we covered how to something something something darkside. If there's a specific scenario that you wish to be covered in future articles, please create a **[New Issue](https://github.com/starkfell/100DaysOfIaC/issues)** in the [starkfell/100DaysOfIaC](https://github.com/starkfell/100DaysOfIaC/) GitHub repository.
