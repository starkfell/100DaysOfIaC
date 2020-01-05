# Day 71 - Deploying a Private Kubernetes Cluster in Azure - Part 1

*This is the first in a series of posts about the current options available to you for deploying a Private Kubernetes Cluster in Azure.*

***[Day 71 - Deploying a Private Kubernetes Cluster in Azure - Part 1](./day.71.deploying.private.k8s.clusters.in.azure.001.md)***</br>

</br>

[AKS Engine Quickstart](https://github.com/Azure/aks-engine/blob/master/docs/tutorials/quickstart.md)

In today's article we will cover the prerequisites you should have in place before deploying a Kubernetes Cluster using AKS-Engine.

[Installing AKS-Engine on Ubuntu](#installing-aks-engine-on-ubuntu)</br>
[Things to Consider](#things-to-consider)</br>
[Conclusion](#conclusion)</br>

> **NOTE:** This article was tested and written for a Linux Host running Ubuntu 18.04.

</br>

## Installing AKS-Engine on Ubuntu

From a bash prompt, run the following command to install AKS-Engine.

```bash
curl -o get-akse.sh https://raw.githubusercontent.com/Azure/aks-engine/master/scripts/get-akse.sh && \
chmod 700 get-akse.sh && \
./get-akse.sh
```

You should get back the following response.

```console
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100  6077  100  6077    0     0  16162      0 --:--:-- --:--:-- --:--:-- 16162
Downloading https://github.com/Azure/aks-engine/releases/download/v0.43.3/aks-engine-v0.43.3-linux-amd64.tar.gz
Preparing to install aks-engine into /usr/local/bin
aks-engine installed into /usr/local/bin/aks-engine
Run 'aks-engine version' to test.
```

Next, run the following command below to verify AKS-Engine is working

```bash
aks-engine version
```

You should get back the following response

```console
Version: v0.43.3
GitCommit: d9d73c3f6
GitTreeState: clean
```

</br>

## Create a new Resource Group for the Kubernetes Cluster

```bash
/usr/bin/az group create \
--name "100daysk8s" \
--location "westeurope"
```

You should get back the following output.

```json
{
  "id": "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/100daysk8s",
  "location": "westeurope",
  "managedBy": null,
  "name": "100daysk8s",
  "properties": {
    "provisioningState": "Succeeded"
  },
  "tags": null,
  "type": "Microsoft.Resources/resourceGroups"
}
```

</br>

## Generate a new Service Principal for the Kubernetes Cluster

Run the following command to retrieve your Azure Subscription ID and store it in a variable.

```bash
AZURE_SUB_ID=$(az account show --query id --output tsv)
```

If the above command doesn't work, manually add your Azure Subscription ID to the variable.

```bash
AZURE_SUB_ID="00000000-0000-0000-0000-000000000000"
```

</br>

Next, run the following command randomly generate 4 alphanumeric characters. This will be appended to the name of the Kubernetes Cluster for uniqueness.

```bash
RANDOM_ALPHA=$(cat /dev/urandom | tr -dc 'a-z0-9' | fold -w 4 | head -n 1)
```

</br>

```bash
/usr/bin/az ad sp create-for-rbac \
--role="Contributor" \
--name="http://100daysk8s${RANDOM_ALPHA}" \
--years 50 \
--scopes="/subscriptions/$AZURE_SUBSCRIPTION_ID/resourceGroups/100daysk8s"
```

## Generate Service Principals for AAD Authentication

```bash

```

## Generate a random Password

Run the following command to generate a password to use with the SSH Keys.

```bash
SSH_KEY_PASSWORD=$(openssl rand -base64 20)
```

## Generate a new pair of SSH Keys for the Kubernetes Cluster

Next, run the following command to generate SSH Keys for the Kubernetes Cluster.

```bash
ssh-keygen \
-t rsa \
-b 4096 \
-C "100daysk8s${RANDOM_ALPHA}" \
-f ~/.ssh/100daysk8s${RANDOM_ALPHA} \
-N "$SSH_KEY_PASSWORD"
```

You should get back a similar response.

```console
Generating public/private rsa key pair.
Your identification has been saved in /home/serveradmin/.ssh/100daysk8simdf.
Your public key has been saved in /home/serveradmin/.ssh/100daysk8simdf.pub.
The key fingerprint is:
SHA256:KqwzbZU3tWA5kAvOCQBoHYKLf09Q1ndJu6HsYfokshQ 100daysk8simdf
The key's randomart image is:
+---[RSA 4096]----+
|*o...  o   ...   |
|o.o.. = . . o.   |
|o. + = o o .o    |
|o   = . =... o   |
| .   .EoS+=..    |
|  ... +oo+..     |
|   oo++.o.o      |
|  o.oo.o +       |
|  .+  .   .      |
+----[SHA256]-----+
```

Next, run the following command to store the SSH Public and Private Key values in Variables and simultaneously delete the Keys locally.

```bash
SSH_PUBLIC_KEY=$(cat ~/.ssh/100-days-linux-vm.pub) && \
SSH_PRIVATE_KEY=$(cat ~/.ssh/100-days-linux-vm) && \
rm -rf ~/.ssh/100-days-linux-vm*
```


## Next Day - Create the Template and Deploy the Cluster

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
      "dnsPrefix": "100daysk8s",
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