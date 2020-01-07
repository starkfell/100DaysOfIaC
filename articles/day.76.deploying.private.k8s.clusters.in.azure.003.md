# Day 76 - Deploying a Private Kubernetes Cluster in Azure - Part 3

*This is the third in a series of posts on deploying and managing a Private Kubernetes Cluster in Azure.*

***[Day 72 - Deploying a Private Kubernetes Cluster in Azure - Part 1](./day.72.deploying.private.k8s.clusters.in.azure.001.md)***</br>
***[Day 73 - Deploying a Private Kubernetes Cluster in Azure - Part 2](./day.73.deploying.private.k8s.clusters.in.azure.002.md)***</br>

</br>

In today's article we will cover how to access the Private Kubernetes Cluster.

[Creating the AKS-Engine Cluster Definition](#creating-the-aks-engine-cluster-definition)</br>
[Things to Consider](#things-to-consider)</br>
[Conclusion](#conclusion)</br>

## Accessing the Kubernetes Cluster

## Create a new Subnet in the Kubernetes VNet

Retrieve the current name of the existing Kubernetes Cluster VNet.

```bash
K8S_VNET_NAME=$(az network vnet list \
--resource-group k8s-100days-iac \
--query [].name \
--output tsv)
```

Next, run the following command to create a new Subnet for the Kubernetes Jumpbox Container in the VNet.

```bash
az network vnet subnet create \
--name jumpbox-subnet \
--vnet-name $K8S_VNET_NAME \
--resource-group k8s-100days-iac \
--address-prefixes 10.239.1.0/24
```

You should get back output similar to what is shown below.

```json
{
  "addressPrefix": "10.239.1.0/24",
  "addressPrefixes": null,
  "delegations": [],
  "etag": "W/\"11310705-738b-40e3-bc4f-31d6c37749b9\"",
  "id": "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/k8s-100days-iac/providers/Microsoft.Network/virtualNetworks/k8s-vnet-90842542/subnets/jumpbox-subnet",
  "ipConfigurationProfiles": null,
  "ipConfigurations": null,
  "name": "jumpbox-subnet",
  "natGateway": null,
  "networkSecurityGroup": null,
  "privateEndpointNetworkPolicies": "Enabled",
  "privateEndpoints": null,
  "privateLinkServiceNetworkPolicies": "Enabled",
  "provisioningState": "Succeeded",
  "purpose": null,
  "resourceGroup": "k8s-100days-iac",
  "resourceNavigationLinks": null,
  "routeTable": null,
  "serviceAssociationLinks": null,
  "serviceEndpointPolicies": null,
  "serviceEndpoints": null,
  "type": "Microsoft.Network/virtualNetworks/subnets"
}
```

</br>

## Deploying the Kubernetes Jumpbox Container

Next, run the following command to deploy an Azure Container Instance to connecting to the Kubernetes Cluster.

```bash
az container create \
--name k8s-jumpbox \
--resource-group k8s-100days-iac \
--image starkfell/k8s-jumpbox \
--ip-address private \
--vnet $K8S_VNET_NAME \
--subnet jumpbox-subnet \
--secure-environment-variables \
"SSH_KEY_PASSWORD"="$SSH_KEY_PASSWORD" \
"K8S_SSH_PRIVATE_KEY"="$SSH_PRIVATE_KEY" \
"K8S_SSH_PRIVATE_KEY_NAME"="k8s-100days-iac-${RANDOM_ALPHA}"
```

Next, run the following command to **echo** out the SSH Private Key to a file from it's environment variable on the Azure Container Instance.

```bash
echo "$K8S_SSH_PRIVATE_KEY" > $K8S_SSH_PRIVATE_KEY_NAME && \
chmod 0600 $K8S_SSH_PRIVATE_KEY_NAME
```

</br>

Next, run the following command to retrieve the Master kubeconfig File from the Kubernetes Master Host.

```bash
sshpass -P "pass" \
-p $SSH_KEY_PASSWORD /usr/bin/scp \
-o "StrictHostKeyChecking=no" \
-o "UserKnownHostsFile=/dev/null" \
-i "$K8S_SSH_PRIVATE_KEY_NAME" \
linuxadmin@10.255.255.5:/home/linuxadmin/.kube/config master-kubeconfig
```

Next, run the following command to set **kubectl** to target the Private Kubernetes Cluster.

```bash
export KUBECONFIG=./master-kubeconfig
```

Next, run the following command to verify you can connect to the Cluster.

```bash
kubectl cluster-info
```

You should get back the following output.

```c
Kubernetes master is running at https://10.255.255.5:443
CoreDNS is running at https://10.255.255.5:443/api/v1/namespaces/kube-system/services/kube-dns:dns/proxy
kubernetes-dashboard is running at https://10.255.255.5:443/api/v1/namespaces/kube-system/services/https:kubernetes-dashboard:/proxy
Metrics-server is running at https://10.255.255.5:443/api/v1/namespaces/kube-system/services/https:metrics-server:/proxy

To further debug and diagnose cluster problems, use 'kubectl cluster-info dump'.
```
