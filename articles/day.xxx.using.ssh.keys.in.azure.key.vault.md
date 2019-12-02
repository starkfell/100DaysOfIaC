# Day XXX - Using SSH Keys in Azure Key Vault for Authentication on Linux VMs

The purpose of this article is to demonstrate that it's possible to generate SSH Keys for Linux, create a Linux VM, and then use the same SSH Keys and Password to authenticate to the VM without ever having to see the password and just use it strictly from Azure Key Vault.

## Generate a new Password for the SSH Keys

Run the following command to generate a random SSH Password

```bash
SSH_KEY_PASSWORD=$(openssl rand -base64 20)
```

## Generate our SSH Keys

Run the following command to generate SSH Keys for the Linux VM.

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
SHA256:IWxv/IE4XNDnlVyB7DG4dhM9hbjK8a/C7x0IxCHfUso 100-days-linux-vm
The key's randomart image is:
+---[RSA 4096]----+
|      ... .+.*o+.|
|     . ..=o=@ +  |
|      + ooE+.= . |
|     o * +=.=    |
|      + Soo= .   |
|       o .oo..   |
|         .. ...  |
|          o  ... |
|           ++..  |
+----[SHA256]-----+
```

Next, run the following command to store the SSH Public and Private Key values in Variables.

```bash
SSH_PUBLIC_KEY=$(cat ~/.ssh/100-days-linux-vm.pub) && \
SSH_PRIVATE_KEY=$(cat ~/.ssh/100-days-linux-vm)
```

## Create a new Resource Group and Azure Key Vault

Next, run the following command to create a new Resource Group

```bash
az group create \
--name "100-days-linux-vm" \
--location "westeurope"
```

You should get back a similar response.

```console
{
  "id": "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/100-days-linux-vm",
  "location": "westeurope",
  "managedBy": null,
  "name": "100-days-linux-vm",
  "properties": {
    "provisioningState": "Succeeded"
  },
  "tags": null,
  "type": "Microsoft.Resources/resourceGroups"
}
```

Next, run the following command to create a new Azure Key Vault

```bash
az keyvault create \
--name "iac100dayslinuxvmkv" \
--resource-group "100-days-linux-vm" \
--output table
```

You should get back a similar response.

```console
Location    Name                 ResourceGroup
----------  -------------------  -----------------
westeurope  iac100dayslinuxvmkv  100-days-linux-vm
```

## Add the SSH Keys and Password to the Azure Key Vault

Next, run the following command to add the SSH Public Key to the Key Vault as a Secret.

```bash
az keyvault secret set \
--name "100-days-linux-vm-pub" \
--vault-name "iac100dayslinuxvmkv" \
--value "$SSH_PUBLIC_KEY" \
--output none
```

Next, run the following command to add the SSH Private Key to the Key Vault as a Secret.

```bash
az keyvault secret set \
--name "100-days-linux-vm" \
--vault-name "iac100dayslinuxvmkv" \
--value "$SSH_PRIVATE_KEY" \
--output none
```

Finally, the following command to add the SSH Private Key Password Key to the Key Vault as a Secret.

```bash
az keyvault secret set \
--name "100-days-linux-vm-password" \
--vault-name "iac100dayslinuxvmkv" \
--value "$SSH_KEY_PASSWORD" \
--output none
```

</br>

## Deploy a new Linux VM in Azure

Run the following command to deploy a new Linux VM using the SSH Keys we just generated.

```bash
az vm create \
--resource-group "100-days-linux-vm" \
--name "100dayslinuxvm" \
--image UbuntuLTS \
--public-ip-address-allocation dynamic \
--public-ip-address-dns-name "iac-100-linux-vm" \
--admin-username "100daysiac" \
--ssh-key-values "$(echo $SSH_PUBLIC_KEY)" \
--output table
```

## Login to the Linux VM using your SSH Key and Password
