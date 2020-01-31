# Day 89 - Options for Managing Access Security to Azure Storage

Need to share data hosted in Azure Storage? With two very different options for granting, you may ask “which option is best?”. It pays to know your options, and the capabilities (or limitations) of each. We'll touch on the options for securing access to Azure storage, and start digging into the topic of Azure Key Vault integration in the Infrastructure-as-Code context. 

If you're looking back in the "100 Days" series, we touch on various aspects of storage in several installments, including:

- [Day 22 - Azure Storage and Secrets in Infrastructure-as-Code (Part 1)](https://github.com/starkfell/100DaysOfIaC/blob/master/articles/day.22.storage.secrets.md)
- [Day 23 - Storage and Secrets in Infrastructure-as-Code (Part 2)](https://github.com/starkfell/100DaysOfIaC/blob/master/articles/day.23.storage.secrets.pt2.md)
- [Day 24 - Storage and Secrets in Infrastructure-as-Code (Part 3)](https://github.com/starkfell/100DaysOfIaC/blob/master/articles/day.24.storage.secrets.pt3.md)
- [Day 29 - Build Pipelines, using Variables (Windows Edition)](https://github.com/starkfell/100DaysOfIaC/blob/master/articles/day.29.build.pipes.encrypted.variables.windows.md)
- [Day 30 - Build Pipelines, using Variables (Linux Edition)](https://github.com/starkfell/100DaysOfIaC/blob/master/articles/day.30.build.pipes.encrypted.variables.linux.md)
- [Day 42 - Deploy Linked ARM Templates Using Storage Account in YAML Pipeline](https://github.com/starkfell/100DaysOfIaC/blob/master/articles/day.42.deploy.nested.arm.templates.using.storage.accounts.in.yaml.pipeline.md)
- [Day 66 - Pipeline-friendly Azure Files Script](https://github.com/starkfell/100DaysOfIaC/blob/master/articles/day.66.azure.file.cli.md)

In this article:

- [Shared Keys](#shared-keys)
- [Shared Access Signatures (SAS)](#shared-access-signatures-sas)
- [Azure AD Authentication](#azure-ad-authentication)
- [Which is best?](#which-is-best)
- [Key Vault Integration](#key-vault-integration)

## Shared Keys
[Shared Key](https://docs.microsoft.com/en-us/rest/api/storageservices/authorize-with-shared-key) is exactly what it sounds like: a key (in cryptographic terms, a string of bits used by an algorithm) you share with those to whom you would like to delegate access. This is equivalent to giving root access to a storage account. It grants all privileges to whomever has the key, from anywhere at anytime until the key is revoked or rolled over.

[HOW-TO: Authorize with Shared Key](https://docs.microsoft.com/en-us/rest/api/storageservices/authorize-with-shared-key)

## Shared Access Signatures (SAS)

Shared Access Signatures allow you to scope duration, privileges, and even which IP addresses are allowed to connect. By distributing a shared access signature URI to a client, you can grant them access to a resource for a specified period of time, with a specified set of permissions. You can scope access with *account-level SAS* (one or multiple services in the storage account) or *service-Level SAS*, which delegates access to resource in just one service (like Queues only, Files only, etc.). There is also *user delegation SAS*, introduced with version 2018-11-09. A user delegation SAS is secured with Azure AD credentials.

Additionally, a service SAS can reference a stored access policy that provides an additional level of control over a set of signatures, including the ability to modify or revoke access to the resource if necessary. SAS is the route that offers the tightest control over access scope and duration.

[HOW-TO: Delegating Access with a Shared Access Signature](https://docs.microsoft.com/en-us/rest/api/storageservices/delegating-access-with-a-shared-access-signature)

## Azure AD Authentication

There is a relatively new method that allows using Azure AD to grant authorization. Unfortunately it’s only supported for Blob and Queue services, so if you use Table Storage, this wont help. Use Shared Key to authorize requests to Table storage. For the services it supports, it’s no doubt going to become a preferred method of granting access in many scenarios.

Azure Files supports authorization with Azure AD over SMB, but for domain-joined VMs only. For details, check out ["Overview of Azure Active Directory authorization over SMB for Azure Files."]([Overview of Azure Active Directory authorization over SMB for Azure Files](https://docs.microsoft.com/en-us/azure/storage/files/storage-files-active-directory-overview))

Azure Data Plane security: https://docs.microsoft.com/en-us/azure/storage/common/storage-security-guide#data-plane-security
Authenticate access to Azure Storage using Azure Active Directory: https://docs.microsoft.com/en-us/azure/storage/common/storage-auth-aad

## Which is best?

The short answer is "it depends". Since not every option supported every service, you'll need to weigh your options for each use case.

## Key Vault Integration

If you are working with ARM templates, you can leverage the [KeyVaultProperties object](#https://docs.microsoft.com/en-us/javascript/api/azure-arm-storage/KeyVaultProperties?view=azure-node-legacy&viewFallbackFrom=azure-node-2.2.0) to interact with Azure Key Vault in deployment scenarios. 

You can also leverage Azure CLI, with the `az keyvault` and `az storage account` commands.

We'll dig into some details of Azure Key Vault in the near future.

## Conclusion

So, keep an eye out for Key Vault discussions in the next day or two, when we'll dig into Key Vault in the context of Azure storage scenarios.
