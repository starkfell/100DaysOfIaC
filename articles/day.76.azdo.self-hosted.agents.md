# Day 76 - Azure DevOps Self-Hosted Agents

*Today's post comes from guest contributor Tao Yang [@MrTaoYang](https://twitter.com/mrtaoyang). Tao is a Microsoft MVP who from 9-to-5 focuses on DevOps and governance in Azure for enterprise customers. You can find Tao blogging at [Managing Cloud and Datacenter by Tao Yang](https://blog.tyang.org/).*

## Overview

When developing an Azure DevOps pipeline, you need to select the an agent pool for each job. Microsoft offers a variety of pipeline agent images you can choose from. These images range from various Windows and Linux VMs, as well as MacOS and Windows containers.

In addition to the Microsoft-hosted agents, you can also use self-hosted agents that are dedicated to your own Azure DevOps instance. Although Microsoft-hosted agents should satisfy most of your Azure IaC pipeline requirements, but in some cases self-hosted agents are required.

***
SPONSOR: Need to stop and start your development VMs on a schedule? The Azure Resource Scheduler let's you schedule up to 10 Azure VMs for FREE! Learn more [HERE](https://azuremarketplace.microsoft.com/en-us/marketplace/apps/lumagatena.resourcescheduler?tab=Overview)
***

## Why Self-Hosted Agents?

These are the common scenarios for self-hosted agents:

### 1. Location

Microsoft-hosted agents are located on the cloud, although they can talk to the Azure Resource Manager APIs to deploy resources to your subscriptions, they do not have connectivity to your private networks - either your on-premises networks, or within your Azure VNets (or even your AWS and GCP VPCs).

If your pipeline requires you to connect to a private endpoint that's only accessible within your VNets or on-premises networks (i.e. remotely executing a script against a VM via SSH or WinRM, or invoking a REST API that's located in your private network, etc.)

You may also find in some environments that Azure AD Conditional Access policies are configured in a way to only allow accessing to your Azure environments from a list of trusted locations. If the IP ranges for Microsoft-hosted agents are not configured as trusted locations, Microsoft-hosted agents may not be able to deploy ARM templates to these subscriptions.

### 2. Installing Additional Applications

Although Microsoft-hosted agents already have all the most common tools and utilities installed, but sometimes you do need to install additional applications, packages, PowerShell modules, etc. In this case, it's more convenient to have them pre-installed on your self-hosted agents - since not everything can be installed as part of the pipeline under user context (without administrative permission to the OS).

### 3. Operating System Requirements

Microsoft-hosted agent pool offers several Windows server images ranges, as well as MacOS and Linux. At the time of writing this article, with MacOS and Linux, only Mojave MacOS and Ubuntu Linux are offered.

If you require other MacOS version or Linux distros (such as CentOS, RHEL or SUSE, etc.), you can install self-hosted agents on VMs or Docker container images.

### 4. Cost and Pricing Tier

Azure Pipelines is charged per job execution minute. It offers a free tier:

* **Microsoft-hosted agents:** 1,800 minutes free per month with 1 free parallel job
* **Self-hosted agents:** 1 free parallel job with unlimited minutes

If the minutes offered by the free tier for Microsoft-hosted agents is not enough, you may create your own self-hosted agents for your pipelines.

>**NOTE:** The pricing details for Azure DevOps can be found here: https://azure.microsoft.com/en-us/pricing/details/devops/azure-devops-services/

## Installing Self-Hosted Agents

Prior to installing self-hosted agents, you must firstly create an agent pool, and generate a Personal Access Token (PAT) for an user account (used for registering agents to the pool).

Microsoft provides great instructions on how to install self-hosted agents:

* [Agent Pool](https://docs.microsoft.com/en-us/azure/devops/pipelines/agents/pools-queues?view=azure-devops&WT.mc_id=DOP-MVP-5000997)
* [Linux agents](https://docs.microsoft.com/en-us/azure/devops/pipelines/agents/v2-linux?view=azure-devops&WT.mc_id=DOP-MVP-5000997)
* [Windows agents](https://docs.microsoft.com/en-us/azure/devops/pipelines/agents/v2-windows?view=azure-devops&WT.mc_id=DOP-MVP-5000997)
* [MacOS agents](https://docs.microsoft.com/en-us/azure/devops/pipelines/agents/v2-osx?view=azure-devops&WT.mc_id=DOP-MVP-5000997)
* [Docker container (both Windows and Linux)](https://docs.microsoft.com/en-us/azure/devops/pipelines/agents/docker?view=azure-devops&WT.mc_id=DOP-MVP-5000997)

>**NOTE:** The dockerfile for the Linux agent provided in Microsoft's documentation is for Ubuntu agent. If you want to create a Linux container image based on another distro (i.e. CentOS), you will need to develop your own from scratch.

When installing self-hosted agents on VMs, keep in mind that you can install multiple agent instances on a same VM. This is particularly important when you are operating within a large Azure DevOps environment that the agent pool is used by multiple projects and pipelines. If you have purchased additional parallel jobs and are using self-hosted agents, you need to make sure you have enough agents to execute those jobs concurrently. Having being able to install multiple instances of the agent on a same VM greatly reduced number of VMs required. Having said that, it is still better to have more than one VM in a agent pool for High Availability configuration. For example, you may dedicate 2 VMs for a self-hosted agent pool, and install 3 agent instances on each VM. This will give you totally 6 agents in the agent pool.

## Conclusion

In this post, I have discussed why self-hosted agents are necessary and to get you started, I have also shared links to Microsoft documentations for self-hosted agent installation instructions.
