# Day 69 - Managing Access to Linux VMs using Azure Key Vault - Part 2

*This is the third in a series of posts about the options available to you to manage your Linux VMs in Azure using Azure Key Vault and how you can adapt this process in a YAML Pipeline. The other posts in this Series can be found below.*

***[Day 68 - Managing Access to Linux VMs using Azure Key Vault - Part 1](./day.68.manage.access.to.linux.vms.using.key.vault.part.1.md)***</br>
***[Day 69 - Managing Access to Linux VMs using Azure Key Vault - Part 2](./day.69.manage.access.to.linux.vms.using.key.vault.part.2.md)***</br>
***[Day 70 - Managing Access to Linux VMs using Azure Key Vault - Part 3](./day.70.manage.access.to.linux.vms.using.key.vault.part.3.md)***</br>

</br>

> **NOTE:** This article was tested and written for a Linux Host running Ubuntu 18.04 with Azure CLI installed.

</br>

In today's article we will cover the following topics.

[deploy-managed-linux.sh Script](#deploy-managed-linuxsh-script)</br>
[Things to Consider](#things-to-consider)</br>
[Conclusion](#conclusion)</br>

## deploy-managed-linux-vm.sh Script

Below is a script that utilizes the material we covered in Day 68 and 69 to deploy a managed Linux VM in Azure.

```bash

#!/bin/bash

# Author:      Ryan Irujo
# Name:        deploy-managed-linux-vm.sh
# Description: Generates a set of SSH Keys and Password and then deploys a new Resource Group and Azure Key Vault and then adds the
#              SSH Keys and Password to it. Lastly, it deploys a Linux VM using the generated SSH Keys.

# Installing sshpass
INSTALL_SSH_PASS=$(sudo apt-get install -y sshpass)

if [ $? -eq 0 ]; then
    echo "[---success---] Installed sshpass."
else
    echo "[---fail------] Failed to install sshpass."
    echo $INSTALL_SSH_PASS
    exit 2
fi

# Generating a new Password for the SSH Private Key.
SSH_KEY_PASSWORD=$(openssl rand -base64 20)

if [ $? -eq 0 ]; then
    echo "[---success---] Generated a random password for SSH Private Key."
else
    echo "[---fail------] Failed to generate a random password for SSH Private Key."
    echo $SSH_KEY_PASSWORD
    exit 2
fi

# Generating new SSH Keys.
GENERATE_NEW_SSH_KEYS=$(ssh-keygen \
-t rsa \
-b 4096 \
-C "100-days-linux-vm" \
-f ~/.ssh/100-days-linux-vm \
-N "$SSH_KEY_PASSWORD")

if [ $? -eq 0 ]; then
    echo "[---success---] Generated new SSH Keys."
else
    echo "[---fail------] Failed to generate new SSH Keys."
    echo $GENERATE_NEW_SSH_KEYS
    exit 2
fi

# Adding the SSH Keys to variables and removing the generated Keys locally.
SSH_PUBLIC_KEY=$(cat ~/.ssh/100-days-linux-vm.pub) && \
SSH_PRIVATE_KEY=$(cat ~/.ssh/100-days-linux-vm) && \
rm -rf ~/.ssh/100-days-linux-vm*

if [ $? -eq 0 ]; then
    echo "[---success---] Added the SSH Keys to variables and removed the generated Keys locally."
else
    echo "[---fail------] Failed to add the SSH Keys to variables and remove the generated Keys locally."
    exit 2
fi

# Creating a new Resource Group.
CREATE_RESOURCE_GROUP=$(az group create \
--name "100-days-linux-vm" \
--location "westeurope" \
--output none)

if [ $? -eq 0 ]; then
    echo "[---success---] Deployed Resource Group [100-days-linux-vm]."
else
    echo "[---fail------] Failed to deploy Resource Group [100-days-linux-vm]."
    echo $CREATE_RESOURCE_GROUP
    exit 2
fi

# Creating a new Azure Key Vault.
CREATE_AZURE_KV=$(az keyvault create \
--name "iac100dayslinuxkv" \
--resource-group "100-days-linux-vm" \
--output none)

if [ $? -eq 0 ]; then
    echo "[---success---] Deployed Key Vault [iac100dayslinuxkv] to Resource Group [100-days-linux-vm]."
else
    echo "[---fail------] Failed to deploy Key Vault [iac100dayslinuxkv] to Resource Group [100-days-linux-vm]."
    echo $CREATE_AZURE_KV
    exit 2
fi

az keyvault secret set \
--name "100-days-linux-vm-pub" \
--vault-name "iac100dayslinuxkv" \
--value "$SSH_PUBLIC_KEY" \
--output none

az keyvault secret set \
--name "100-days-linux-vm" \
--vault-name "iac100dayslinuxkv" \
--value "$SSH_PRIVATE_KEY" \
--output none

az keyvault secret set \
--name "100-days-linux-vm-password" \
--vault-name "iac100dayslinuxkv" \
--value "$SSH_KEY_PASSWORD" \
--output none

az vm create \
--resource-group "100-days-linux-vm" \
--name "100dayslinuxvm" \
--image UbuntuLTS \
--public-ip-address-allocation dynamic \
--public-ip-address-dns-name "iac-100-linux-vm" \
--admin-username "lxvmadmin" \
--ssh-key-values "$SSH_PUBLIC_KEY" \
--output table

SSH_PRIVATE_KEY=$(/usr/bin/az keyvault secret download \
--name "100-days-linux-vm" \
--vault-name "iac100dayslinuxkv" \
--file "/tmp/100-days-linux-vm" \
--output tsv 2>&1)

chmod 0600 "/tmp/100-days-linux-vm"

export SSHPASS=$(/usr/bin/az keyvault secret show \
--name "100-days-linux-vm-password" \
--vault-name "iac100dayslinuxkv" \
--query value \
--output tsv 2>&1)

sshpass \
-P "pass" \
-e \
ssh \
-o "StrictHostKeyChecking=no" \
-o "UserKnownHostsFile=/dev/null" \
-i "/tmp/100-days-linux-vm" \
lxvmadmin@iac-100-linux-vm.westeurope.cloudapp.azure.com

rm -f "/tmp/100-days-linux-vm"

export SSHPASS=""

```


</br>

## Things to Consider

When using **sshpass**, you have the option to use **-p** option to directly pass in the password you want to use; however, the password will then appear in cleartext in **ps** output. This is why we used the **-e** option instead to store the SSH Private Key Password in the environment variable **SSHPASS**. Be aware, that this has its own security risks as well if the Linux Host you are working from is ever compromised.

</br>

## Conclusion

In today's article in we continued where we left off in **[Part 8](./day.51.building.a.practical.yaml.pipeline.part.8.md)** and added in the deployment of an Azure Container Instance using the NGINX Image from our Azure Container Registry **pracazconreg**. If there's a specific scenario that you wish to be covered in future articles, please create a **[New Issue](https://github.com/starkfell/100DaysOfIaC/issues)** in the [starkfell/100DaysOfIaC](https://github.com/starkfell/100DaysOfIaC/) GitHub repository.
