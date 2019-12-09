# Day 69 - Managing Access to Linux VMs using Azure Key Vault - Part 2

*This is the second in a series of posts about the options available to you to manage your Linux VMs in Azure using Azure Key Vault and how you can adapt this process in a YAML Pipeline. The other posts in this Series can be found below.*

***[Day 68 - Managing Access to Linux VMs using Azure Key Vault - Part 1](./day.68.manage.access.to.linux.vms.using.key.vault.part.1.md)***</br>
***[Day 69 - Managing Access to Linux VMs using Azure Key Vault - Part 2](./day.69.manage.access.to.linux.vms.using.key.vault.part.2.md)***</br>

</br>

> **NOTE:** This article was tested and written for a Linux Host running Ubuntu 18.04 with Azure CLI installed.

</br>

In today's article we will cover the following topics.

[Install sshpass](#install-sshpass)</br>
[Retrieve the SSH Private Key from Key Vault](#retrieve-the-ssh-private-key-from-key-vault)</br>
[Retrieve the SSH Private Key Password from Key Vault](#retrieve-the-ssh-private-key-password-from-key-vault)</br>
[Login to the Linux VM using your SSH Key and Password](#login-to-the-linux-vm-using-your-ssh-key-and-password)</br>
[Things to Consider](#things-to-consider)</br>
[Conclusion](#conclusion)</br>

## Install sshpass

**[sshpass](https://linux.die.net/man/1/sshpass)** is a command line tool that allows you to provide a password for non-interactive-password authentication inside a bash prompt.

Run the following command to install **sshpass**.

```bash
sudo apt-get install -y sshpass
```

You should get back the following response.

```console
Reading package lists... Done
Building dependency tree
Reading state information... Done
The following NEW packages will be installed:
  sshpass
0 upgraded, 1 newly installed, 0 to remove and 58 not upgraded.
Need to get 10.5 kB of archives.
After this operation, 30.7 kB of additional disk space will be used.
Get:1 http://at.archive.ubuntu.com/ubuntu bionic/universe amd64 sshpass amd64 1.06-1 [10.5 kB]
Fetched 10.5 kB in 0s (78.7 kB/s)
Selecting previously unselected package sshpass.
(Reading database ... 182191 files and directories currently installed.)
Preparing to unpack .../sshpass_1.06-1_amd64.deb ...
Unpacking sshpass (1.06-1) ...
Setting up sshpass (1.06-1) ...
Processing triggers for man-db (2.8.3-2ubuntu0.1) ...
```

</br>

## Retrieve the SSH Private Key from Key Vault

Run the following command to retrieve the SSH Private Key from the Key Vault and store it in **/tmp**.

```bash
SSH_PRIVATE_KEY=$(/usr/bin/az keyvault secret download \
--name "100-days-linux-vm" \
--vault-name "iac100dayslinuxkv" \
--file "/tmp/100-days-linux-vm" \
--output tsv 2>&1)
```

Next, run the following command to change the permissions on the SSH Private Key to **0600**.

```bash
chmod 0600 "/tmp/100-days-linux-vm"
```

</br>

## Retrieve the SSH Private Key Password from Key Vault

Run the following command to retrieve the SSH Private Key from the Key Vault and store it into the environment variable, **SSHPASS**.

```bash
export SSHPASS=$(/usr/bin/az keyvault secret show \
--name "100-days-linux-vm-password" \
--vault-name "iac100dayslinuxkv" \
--query value \
--output tsv 2>&1)
```

</br>

## Login to the Linux VM using your SSH Key and Password

Next, run the following command to login to the Linux VM via SSH

```bash
sshpass \
-P "pass" \
-e \
ssh \
-o "StrictHostKeyChecking=no" \
-o "UserKnownHostsFile=/dev/null" \
-i "/tmp/100-days-linux-vm" \
lxvmadmin@iac-100-linux-vm.westeurope.cloudapp.azure.com
```

You should get back the following response where you are then logged into the Linux VM in Azure.

```console
Warning: Permanently added 'iac-100-linux-vm.westeurope.cloudapp.azure.com,40.115.61.255' (ECDSA) to the list of known hosts.
Welcome to Ubuntu 18.04.3 LTS (GNU/Linux 5.0.0-1027-azure x86_64)

 * Documentation:  https://help.ubuntu.com
 * Management:     https://landscape.canonical.com
 * Support:        https://ubuntu.com/advantage

  System information as of Sun Dec  8 13:27:30 UTC 2019

  System load:  0.02              Processes:           107
  Usage of /:   4.1% of 28.90GB   Users logged in:     0
  Memory usage: 9%                IP address for eth0: 10.0.0.4
  Swap usage:   0%

 * Overheard at KubeCon: "microk8s.status just blew my mind".

     https://microk8s.io/docs/commands#microk8s.status

0 packages can be updated.
0 updates are security updates.


Last login: Sun Dec  8 13:25:39 2019 from 213.47.155.102
To run a command as administrator (user "root"), use "sudo <command>".
See "man sudo_root" for details.

lxvmadmin@100dayslinuxvm:~$
```

</br>

When you are finished, logout of the Linux VM and then run the command below to delete the Private Key from your Host.

```bash
rm -f "/tmp/100-days-linux-vm"
```

Next, set the SSHPASS Environment Variable to a value of null.

```bash
export SSHPASS=""
```

</br>

## Things to Consider

When using **sshpass**, you have the option to use **-p** option to directly pass in the password you want to use; however, the password will then appear in cleartext in **ps** output. This is why we used the **-e** option instead to store the SSH Private Key Password in the environment variable **SSHPASS**. Be aware, that this has its own security risks as well if the Linux Host you are working from is ever compromised.

While you are busy automating your processes for using the Private SSH Key to deploy and manage a Linux Host, make sure you are removing the Private Key from Host that you are using it from and setting the **SSHPASS** environment variable to null before you finish your automation process.

</br>

## Conclusion

In today's article in we deployed a Linux VM using the SSH Keys and Password from Azure Key Vault. If there's a specific scenario that you wish to be covered in future articles, please create a **[New Issue](https://github.com/starkfell/100DaysOfIaC/issues)** in the [starkfell/100DaysOfIaC](https://github.com/starkfell/100DaysOfIaC/) GitHub repository.

On the 69th Day of our 100 Days of Infrastructure-as-Code in Azure, we would like to leave you with a quote from Bill & Ted that will hopefully make your day a little more cheerful.

![Alt Text](https://media1.tenor.com/images/6d2770c0b678d085385f886011b4462b/tenor.gif?itemid=14399218)
