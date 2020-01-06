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

```bash

```

## Deploying the Kubernetes Jumpbox Container

```bash
az container create \
--name k8s-jumpbox \
--resource-group k8s-100days-iac \
--image starkfell/k8s-jumpbox \
--ip-address private \
--vnet k8s-vnet-30718248 \
--subnet inbound-subnet \
--secure-environment-variables \
"SSH_KEY_PASSWORD"="$SSH_KEY_PASSWORD" \
"K8S_SSH_PRIVATE_KEY"="$SSH_PRIVATE_KEY" \
"K8S_SSH_PRIVATE_KEY_NAME"="k8s-100days-iac-${RANDOM_ALPHA}"


# Need to pass in the Password for the SSH Key for the Master as an Environment Variable
# Second Option is to pass in the kubeconfig file as an environment variable, possibly???

```

```bash
sshpass -P "pass" \
-p $SSH_KEY_PASSWORD /usr/bin/scp \
-o "StrictHostKeyChecking=no" \
-o "UserKnownHostsFile=/dev/null" \
-i "$K8S_SSH_PRIVATE_KEY_NAME" \
linuxadmin@10.255.255.5:/home/linuxadmin/.kube/config master-kubeconfig
```
