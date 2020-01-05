# Day 73 - Deploying a Private Kubernetes Cluster in Azure - Part 2

*This is the first in a series of posts about the current options available to you for deploying a Private Kubernetes Cluster in Azure.*

***[Day 72 - Deploying a Private Kubernetes Cluster in Azure - Part 1](./day.72.deploying.private.k8s.clusters.in.azure.001.md)***</br>
***[Day 73 - Deploying a Private Kubernetes Cluster in Azure - Part 2](./day.73.deploying.private.k8s.clusters.in.azure.002.md)***</br>

[AKS Engine Quickstart](https://github.com/Azure/aks-engine/blob/master/docs/tutorials/quickstart.md)

In today's article we will cover the basics of deploying a new Private Kubernetes Cluster in Azure using AKS-Engine.

[Installing AKS-Engine on Ubuntu](#installing-aks-engine-on-ubuntu)</br>
[Things to Consider](#things-to-consider)</br>
[Conclusion](#conclusion)</br>

> **NOTE:** This article was tested and written for a Linux Host running Ubuntu 18.04.

</br>

## Create the AKS-Engine Cluster Definition

AKS-Engine uses a JSON File called a cluster definition in order generate ARM Templates for deploying the Kubernetes Cluster in Azure. Feel free to check out the **[Examples](github.com/Azure/aks-engine/tree/master/examples)** section on GitHub to see the numerous options available to you.

Copy and paste the contents below into a file called **k8s-private-cluster.json** using **vim** or **nano** on your Ubuntu Host.

```json
{
  "apiVersion": "vlabs",
  "properties": {
    "orchestratorProfile": {
      "orchestratorType": "Kubernetes",
      "orchestratorVersion": "1.15.5",
      "kubernetesConfig": {
        "privateCluster": {
          "enabled": true
        }
      }
    },
    "aadProfile": {
      "serverAppID": "{K8S_APISRV_APP_ID}",
      "clientAppID": "{K8S_APICLI_APP_ID}",
      "tenantID": "{AZURE_SUBSCRIPTION_TENANT_ID}"
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
DNS_PREFIX=$(echo 100daysk8s-${RANDOM_ALPHA})
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
