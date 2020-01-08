# Day 73 - Deploying a Private Kubernetes Cluster in Azure - Part 2

*This is the second in a series of posts on deploying and managing a Private Kubernetes Cluster in Azure.*

***[Day 71 - The Current State of Kubernetes in Azure](./day.71.the.current.state.of.k8s.in.azure.md)***</br>
***[Day 72 - Deploying a Private Kubernetes Cluster in Azure - Part 1](./day.72.deploying.private.k8s.clusters.in.azure.001.md)***</br>
***[Day 73 - Deploying a Private Kubernetes Cluster in Azure - Part 2](./day.73.deploying.private.k8s.clusters.in.azure.002.md)***</br>

</br>

In today's article we will deploy a new Private Kubernetes Cluster in Azure using AKS-Engine.

[Creating the AKS-Engine Cluster Definition](#creating-the-aks-engine-cluster-definition)</br>
[Generate the ARM Templates](#generate-the-arm-templates)</br>
[Deploy the Private Kubernetes Cluster](#deploy-the-private-kubernetes-cluster)</br>
[Things to Consider](#things-to-consider)</br>
[Conclusion](#conclusion)</br>

> **NOTE:** This article was tested and written for a Linux Host running Ubuntu 18.04.

</br>

## Creating the AKS-Engine Cluster Definition

AKS-Engine uses a JSON File called a cluster definition in order generate ARM Templates for deploying the Kubernetes Cluster in Azure. Feel free to check out the **[Examples](github.com/Azure/aks-engine/tree/master/examples)** section on GitHub to see the numerous options available to you.

From a bash prompt, copy and paste the contents below into a file called **k8s-private-cluster.json** using **vim** or **nano** on your Ubuntu Host.

```json
{
  "apiVersion": "vlabs",
  "properties": {
    "orchestratorProfile": {
      "orchestratorType": "Kubernetes",
      "orchestratorVersion": "1.16.1",
      "kubernetesConfig": {
        "privateCluster": {
          "enabled": true
        }
      }
    },
    "masterProfile": {
      "count": 1,
      "dnsPrefix": "{DNS_PREFIX}",
      "vmSize": "Standard_DS2_v2",
      "availabilityProfile": "AvailabilitySet",
      "storageProfile": "ManagedDisks"
    },
    "agentPoolProfiles": [
      {
        "name": "linuxpool1",
        "count": 2,
        "vmSize": "Standard_DS2_v2",
        "availabilityProfile": "AvailabilitySet",
        "storageProfile": "ManagedDisks"
      }
    ],
    "linuxProfile": {
      "adminUsername": "linuxadmin",
      "ssh": {
        "publicKeys": [
          {
            "keyData": "{SSH_PUBLIC_KEY}"
          }
        ]
      }
    },
    "servicePrincipalProfile": {
      "clientId": "{K8S_SP_CLIENT_ID}",
      "secret": "{K8S_SP_CLIENT_PASSWORD}"
    }
  }
}
```

Next, run the following command to create the DNS Prefix of the Kubernetes Cluster.

```bash
DNS_PREFIX=$(echo k8s-100days-iac-${RANDOM_ALPHA})
```

Next, run the following command to add in the Kubernetes DNS Prefix to **k8s-private-cluster.json**.

```bash
sed -i -e "s/{DNS_PREFIX}/$DNS_PREFIX/" ./k8s-private-cluster.json
```

Next, run the following command to add in your SSH Public Key to **k8s-private-cluster.json**.

```bash
sed -i -e "s~{SSH_PUBLIC_KEY}~$SSH_PUBLIC_KEY~" ./k8s-private-cluster.json
```

Next, run the following command to add in the Kubernetes Service Principal Application ID to **k8s-private-cluster.json**.

```bash
sed -i -e "s/{K8S_SP_CLIENT_ID}/$K8S_SP_APP_ID/" ./k8s-private-cluster.json
```

Next, run the following command to add in the Kubernetes Service Principal Application ID to **k8s-private-cluster.json**.

```bash
sed -i -e "s/{K8S_SP_CLIENT_PASSWORD}/$K8S_SP_PASSWORD/" ./k8s-private-cluster.json
```

</br>

## Generate the ARM Templates

Next, run the following command to generate the ARM Templates for deploying the Kubernetes Cluster.

```bash
aks-engine generate \
k8s-private-cluster.json \
--output-directory "k8s-100days-iac-${RANDOM_ALPHA}/"
```

You should get back the following.

```console
INFO[0000] Generating assets into k8s-100days-iac-qqj3/...
```

</br>

## Deploy the Private Kubernetes Cluster

Next, run the following command to deploy the Kubernetes Cluster.

```bash
az group deployment create \
--name "k8s-100days-iac-${RANDOM_ALPHA}-deployment" \
--resource-group "k8s-100days-iac" \
--template-file "k8s-100days-iac-${RANDOM_ALPHA}/azuredeploy.json" \
--parameters "k8s-100days-iac-${RANDOM_ALPHA}/azuredeploy.parameters.json"
```

The deployment of the Kubernetes Cluster will start and run for roughly 10 minutes. When the deployment has finished, you should see the following response near the bottom of the output.

```json
...
    "provisioningState": "Succeeded",
    "template": null,
    "templateHash": "4119629975786823298",
    "templateLink": null,
    "timestamp": "2020-01-06T08:48:36.673205+00:00"
  },
  "resourceGroup": "k8s-100days-iac",
  "type": "Microsoft.Resources/deployments"
}
```

> **NOTE:** You will need the values from the variables in **[Part 1](./day.72.deploying.private.k8s.clusters.in.azure.001.md)** that you used in this article for **[Part 3](./day.74.deploying.private.k8s.clusters.in.azure.003.md)**.

</br>

## Things to Consider

As you may have noticed, the Private Kubernetes Cluster isn't deployed with a Public IP Address so you won't be able to interact with the Kubernetes API externally. This is why Microsoft [recommends](https://docs.microsoft.com/en-us/azure/aks/private-clusters#steps-to-connect-to-the-private-cluster) that you either deploy a VM in the same VNet as the Cluster or create a VM in a different VNet that is peered with the Cluster. In **[Part 3](./day.74.deploying.private.k8s.clusters.in.azure.003.md)**, we are going to show you another option to connect to the Private Kubernetes Cluster from an Azure Container Instance.

</br>

## Conclusion

In today's article we deployed a new Private Kubernetes Cluster in Azure using AKS-Engine. If there's a specific scenario that you wish to be covered in future articles, please create a **[New Issue](https://github.com/starkfell/100DaysOfIaC/issues)** in the [starkfell/100DaysOfIaC](https://github.com/starkfell/100DaysOfIaC/) GitHub repository.
