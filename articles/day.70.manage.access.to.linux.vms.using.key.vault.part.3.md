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

## deploy-managed-linux.sh Script

</br>

## Things to Consider

When using **sshpass**, you have the option to use **-p** option to directly pass in the password you want to use; however, the password will then appear in cleartext in **ps** output. This is why we used the **-e** option instead to store the SSH Private Key Password in the environment variable **SSHPASS**. Be aware, that this has its own security risks as well if the Linux Host you are working from is ever compromised.

</br>

## Conclusion

In today's article in we continued where we left off in **[Part 8](./day.51.building.a.practical.yaml.pipeline.part.8.md)** and added in the deployment of an Azure Container Instance using the NGINX Image from our Azure Container Registry **pracazconreg**. If there's a specific scenario that you wish to be covered in future articles, please create a **[New Issue](https://github.com/starkfell/100DaysOfIaC/issues)** in the [starkfell/100DaysOfIaC](https://github.com/starkfell/100DaysOfIaC/) GitHub repository.
