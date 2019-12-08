# Day 68 - Managing Access to Linux VMs using Azure Key Vault - Part 1

*This is the first in a series of posts about the options available to you to manage your Linux VMs in Azure using Azure Key Vault and how you can adapt this process in a YAML Pipeline. The other posts in this Series can be found below.*

***[Day 68 - Managing Access to Linux VMs using Azure Key Vault - Part 1](./day.68.manage.access.to.linux.vms.using.key.vault.part.1.md)***</br>

</br>

In today's article we will cover the following topics.

[Generate a random Password](#generate-a-random-password)</br>
[Generate new SSH Keys](#generate-new-ssh-keys)</br>
[Deploy a new Resource Group and a new Azure Key Vault](#deploy)</br>
[Add the SSH Keys and Password to the Azure Key Vault](#add-the-ssh-keys-and-password-to-the-azure-key-vault)</br>
[Deploy a new Linux VM in Azure](#deploy-a-new-linux-vm-in-azure)</br>
[Things to Consider](#things-to-consider)</br>
[Conclusion](#conclusion)</br>

## Generate a random Password

Run the following command to generate a password to use with the SSH Keys.

```bash
SSH_KEY_PASSWORD=$(openssl rand -base64 20)
```

> **NOTE:** Since we are using SSH Keys for authentication and not username/password, we aren't required to use the [standard password requirements for Linux VMs in Azure](https://docs.microsoft.com/en-us/azure/virtual-machines/linux/faq#what-are-the-password-requirements-when-creating-a-vm).

</br>

## Generate new SSH Keys

Next, run the following command to generate SSH Keys for the Linux VM.

```bash
ssh-keygen \
-t rsa \
-b 4096 \
-C "100-days-linux-vm" \
-f ~/.ssh/100-days-linux-vm \
-N $SSH_KEY_PASSWORD
```

You should get back a similar response.

```console
Generating public/private rsa key pair.
Your identification has been saved in /home/serveradmin/.ssh/100-days-linux-vm.
Your public key has been saved in /home/serveradmin/.ssh/100-days-linux-vm.pub.
The key fingerprint is:
SHA256:OP8KNpdZjEJMRUTNDNeS91Iu/BvYIRa1HPKTbkedlmg 100-days-linux-vm
The key's randomart image is:
+---[RSA 4096]----+
|      .=*=.o..o  |
|     o   .* ++o++|
|      o    + E*+o|
|     . . o  B.=o |
|      + S o. Bo..|
|       + +  ..+. |
|      + =      o |
|     . + .    .  |
|        ...      |
+----[SHA256]-----+
```

Next, run the following command to store the SSH Public and Private Key values in Variables and simultaneously delete the Keys locally.

```bash
SSH_PUBLIC_KEY=$(cat ~/.ssh/100-days-linux-vm.pub) && \
SSH_PRIVATE_KEY=$(cat ~/.ssh/100-days-linux-vm) && \
rm -rf ~/.ssh/100-days-linux-vm*
```

</br>

## Deploy a new Resource Group and a new Azure Key Vault

Next, run the following command to create a new Resource Group

```bash
az group create \
--name "100-days-linux-vm" \
--location "westeurope" \
--output table
```

You should get back a similar response.

```console
Location    Name
----------  -----------------
westeurope  100-days-linux-vm
```

Next, run the following command to create a new Azure Key Vault

```bash
az keyvault create \
--name "iac100dayslinuxkv" \
--resource-group "100-days-linux-vm" \
--output table
```

You should get back a similar response.

```console
Location    Name                 ResourceGroup
----------  -------------------  -----------------
westeurope  iac100dayslinuxkv  100-days-linux-vm
```

</br>

## Add the SSH Keys and Password to the Azure Key Vault

Next, run the following command to add the SSH Public Key to the Key Vault as a Secret.

```bash
az keyvault secret set \
--name "100-days-linux-vm-pub" \
--vault-name "iac100dayslinuxkv" \
--value "$SSH_PUBLIC_KEY" \
--output none
```

Next, run the following command to add the SSH Private Key to the Key Vault as a Secret.

```bash
az keyvault secret set \
--name "100-days-linux-vm" \
--vault-name "iac100dayslinuxkv" \
--value "$SSH_PRIVATE_KEY" \
--output none
```

Finally, the following command to add the SSH Private Key Password Key to the Key Vault as a Secret.

```bash
az keyvault secret set \
--name "100-days-linux-vm-password" \
--vault-name "iac100dayslinuxkv" \
--value "$SSH_KEY_PASSWORD" \
--output none
```

</br>

## Deploy a new Linux VM in Azure

Run the following command to deploy a new Linux VM using the SSH Keys we just generated.

>**NOTE:** Make sure to use a unique name for the FQDN that is set by the *public-ip-address-dns-name* parameter.

```bash
az vm create \
--resource-group "100-days-linux-vm" \
--name "100dayslinuxvm" \
--image UbuntuLTS \
--public-ip-address-allocation dynamic \
--public-ip-address-dns-name "iac-100-linux-vm" \
--admin-username "lxvmadmin" \
--ssh-key-values "$(echo $SSH_PUBLIC_KEY)" \
--output table
```

</br>

You should get back a similar response when the VM has finished deploying.

```console
ResourceGroup      PowerState    PublicIpAddress    Fqdns                                           PrivateIpAddress    MacAddress         Location    Zones
-----------------  ------------  -----------------  ----------------------------------------------  ------------------  -----------------  ----------  -------
100-days-linux-vm  VM running    40.115.61.255      iac-100-linux-vm.westeurope.cloudapp.azure.com  10.0.0.4            00-0D-3A-AA-AF-28  westeurope
```

</br>

## Things to Consider

Password or not to Password protect your keys. Most large enterprises don't and instead opt to change their SSH Keys on a regular basis and to restrict access to Linux VM's purely using SSH Key authentication and disabling all username/password access.

Microsoft currently only supports RSA public-private key pairs in Azure. Formats such as ED25519 and ECDSA are currently not supported. More information on this can found [here](https://docs.microsoft.com/en-us/azure/virtual-machines/linux/mac-create-ssh-keys).

</br>

## Conclusion

In today's article in we continued where we left off in **[Part 8](./day.51.building.a.practical.yaml.pipeline.part.8.md)** and added in the deployment of an Azure Container Instance using the NGINX Image from our Azure Container Registry **pracazconreg**. If there's a specific scenario that you wish to be covered in future articles, please create a **[New Issue](https://github.com/starkfell/100DaysOfIaC/issues)** in the [starkfell/100DaysOfIaC](https://github.com/starkfell/100DaysOfIaC/) GitHub repository.