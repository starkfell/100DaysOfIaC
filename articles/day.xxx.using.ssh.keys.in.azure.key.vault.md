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

Next, run the following command to store the SSH Public and Private Key values in Variables.

```bash
SSH_PUBLIC_KEY=$(cat ~/.ssh/100-days-linux-vm.pub) && \
SSH_PRIVATE_KEY=$(cat ~/.ssh/100-days-linux-vm)
```

## Create a new Azure Key Vault

## Add the SSH Keys and Password to the Azure Key Vault

## Deploy a new Linux VM in Azure

## Login to the Linux VM using your SSH Key and Password