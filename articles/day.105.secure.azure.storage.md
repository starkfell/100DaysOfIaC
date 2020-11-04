# Day 105 - Azure Storage Security End-to-End

In this session, we'll break down security for Azure Storage end-to-end in a variety of scenarios. Resources from this session are detailed below, along with the link to the video on YouTube.

## In this article

- [YouTube Video](#youtube-video)</br>
- [Related Installments](#related-installments)</br>
- [Related Articles and Tutorials](#related-articles-and-tutorials)</br>
- [Azure Cloud Shell transcript](#azure-cloud-shell-transcript) (from live session)</br>

***
SPONSOR: Need to stop and start your development VMs on a schedule? The Azure Resource Scheduler let's you schedule up to 10 Azure VMs for FREE! Learn more [HERE](https://azuremarketplace.microsoft.com/en-us/marketplace/apps/lumagatena.resourcescheduler?tab=Overview)
***

## YouTube Video

Watch the video on YouTube at [https://youtu.be/C8ZfsVp3qdQ](https://youtu.be/C8ZfsVp3qdQ)

**TO SUBSCRIBE:** Click **[HERE](https://www.youtube.com/channel/UCAr0yk0um7lwLjmrKfzwyig?sub_confirmation=1)** to follow us on Youtube so you get a heads up on future videos!

A few areas of Azure Storage security we covered in this video include:

- Role based access control (RBAC)
- Access Keys
- Shared Access Signatures (SAS)
- Stored Access Policies
- Resource Firewall
- Storage log destinations
- Legal Hold
- Authentication for Azure Files
- Storage Access Key Rotation

([back to top](#in-this-article))

## Related Installments

You will find some additional code samples related to Azure Storage security in the articles below:

[Day 89 - Options for Managing Access Security to Azure Storage](https://github.com/starkfell/100DaysOfIaC/blob/master/articles/day.89.azure.storage.sec.md)</br>

[Day 24 - Azure Storage and Secrets in Infrastructure-as-Code (Part 3)](https://github.com/starkfell/100DaysOfIaC/blob/master/articles/day.24.storage.secrets.pt3.md)</br>

[Day 23 - Azure Storage and Secrets in Infrastructure-as-Code (Part 2)](https://github.com/starkfell/100DaysOfIaC/blob/master/articles/day.23.storage.secrets.pt2.md)</br>

[Day 22 - Azure Storage and Secrets in Infrastructure-as-Code (Part 1)](https://github.com/starkfell/100DaysOfIaC/blob/master/articles/day.22.storage.secrets.md)</br>

([back to top](#in-this-article))

## Related Articles and Tutorials

Here are a few articles on the Microsoft Docs site that are central to the Azure Storage security topics covered in this installment.

[Authorizing access to data in Azure Storage](https://docs.microsoft.com/en-us/azure/storage/common/storage-auth)</br>

[TUTORIAL: Set up Azure Key Vault with key rotation and auditing](https://docs.microsoft.com/en-us/azure/key-vault/key-vault-key-rotation-log-monitoring)</br>

[Rotate storage account access keys with PowerShell](https://docs.microsoft.com/en-us/azure/storage/scripts/storage-common-rotate-account-keys-powershell)</br>

[Manage storage account keys with Key Vault and the Azure CLI](https://docs.microsoft.com/en-us/azure/key-vault/secrets/overview-storage-keys)</br>

[Configure Azure AD authentication for Azure Storage](https://azure.microsoft.com/en-us/blog/azure-storage-support-for-azure-ad-based-access-control-now-generally-available/)</br>

[Overview of Azure Files identity-based authentication support for SMB access](https://docs.microsoft.com/en-us/azure/storage/files/storage-files-active-directory-overview)</br>

[Create SAS tokens and integrate with Azure Key Vault](https://docs.azure.cn/zh-cn/cli/storage/account?view=azure-cli-latest#az-storage-account-generate-sas)</br>

[Grant limited access to Azure Storage resources using shared access signatures (SAS)](https://docs.microsoft.com/en-us/azure/storage/common/storage-sas-overview)</br>

## Azure Cloud Shell Transcript

Below is the Cloud Shell transcript from the Day 105 discussion.

([back to top](#in-this-article))</br>

```bash
az group create \
--name next-100-days-str \
--location westeurope

RANDOM_ALPHA=$(cat /proc/sys/kernel/random/uuid | tr -dc 'a-z0-9' | fold -w 4 | head -n 1)

az storage account create \
--name "next100daysstr${RANDOM_ALPHA}" \
--resource-group next-100-days-str \
--location westeurope \
--sku Standard_LRS \
--kind StorageV2 \
--output table

az storage account keys list \
--account-name "next100daysstr${RANDOM_ALPHA}" \
--resource-group next-100-days-str 

az storage account keys list \
--account-name "next100daysstr${RANDOM_ALPHA}" \
--resource-group next-100-days-str \
--query [0].value \
--output tsv

az storage account keys list \
--account-name "next100daysstr${RANDOM_ALPHA}" \
--resource-group next-100-days-str \
--query [1].value \
--output tsv

KEY_VAL=$(az storage account keys list --account-name "next100daysstr${RANDOM_ALPHA}" --resource-group next-100-days-str --query [1].value --output tsv)
```

## Conclusion

This has been a deep drive into securing Azure Storage. If you've never tried it, try the many code samples we have provided here to get some hands-on practice.

([back to top](#in-this-article))
