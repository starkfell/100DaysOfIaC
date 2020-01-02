# Day 71 - The Current State of Kubernetes in Azure

*This is the first in a series of posts about using Kubernetes in Azure.*

***[Day 71 - The Current State of Kubernetes in Azure](./day.71.the.current.state.of.k8s.in.azure.md)***</br>

</br>

In today's article we will cover the following topics.
[AKS-Engine vs. AKS](#aks-engine-vs-aks)</br>
[Things to Consider](#things-to-consider)</br>
[Conclusion](#conclusion)</br>

## AKS-Engine vs. AKS

Here we are going to discuss some of the basic differences between AKS-Engine and AKS in Azure and the current state of each offering that is publicly available.

|               | Description                 | Features                    | Support                     | Limitations                 |
|---------------|-----------------------------|-----------------------------|-----------------------------|-----------------------------|
| **AKS**       | Managed Version of Kubernetes in Azure | Stuff | Support only for Hardware | severely limited |
| **AKS-Engine**| Self-Managed Version of K8s in Azure   | Stuff | Not Supported directly by Microsoft | unlimited |

The Official documentation on Support policies for Azure Kubernetes Service can be found **[here](https://docs.microsoft.com/en-us/azure/aks/support-policies)**.

One of the big take-aways of using AKS is the following:

> AKS isn't a completely managed cluster solution. Some components, such as worker nodes, have shared responsibility, where users must help maintain the AKS cluster. User input is required, for example, to apply a worker node operating system (OS) security patch.
> The services are managed in the sense that Microsoft and the AKS team deploys, operates, and is responsible for service availability and functionality. Customers can't alter these managed components. Microsoft limits customization to ensure a consistent and scalable user experience. For a fully customizable solution, see AKS Engine.

</br>

### AKS-Engine Features

A comprehensive description of the Features in AKS-Engine, shown in the table below, can be found **[here](github.com/Azure/aks-engine/blob/master/docs/topics/features.md)**.

|Feature|Status|API Version|
|---|---|---|
|Managed Disks|Beta|`vlabs`|
|Calico Network Policy|Alpha|`vlabs`|
|Cilium Network Policy|Alpha|`vlabs`|
|Antrea Network Policy|Alpha|`vlabs`|
|Custom VNET|Beta|`vlabs`|
|Kata Containers Runtime|Alpha|`vlabs`|
|Private Cluster|Alpha|`vlabs`|
|Azure Key Vault Encryption|Alpha|`vlabs`|
|Shared Image Gallery images|Alpha|`vlabs`|
|Ephemeral OS Disks|Experimental|`vlabs`|

</br>

You may notice that the features available in AKS-Engine have three distinct statuses (as of this writing): Alpha, Beta, and Experimental. While this may give you pause in deciding whether to use these features or not, you should be aware of the current **[SLA](https://azure.microsoft.com/en-ca/support/legal/sla/kubernetes-service/v1_0/)** for AKS.

> As a free service, AKS does not offer a financially-backed service level agreement. We will strive to attain at least 99.5% availability for the Kubernetes API server. The availability of the agent nodes in your cluster is covered by the Virtual Machines SLA. Please see the Virtual Machines SLA for more details.

In other words, you are on your own in regards to any of your applications that are running on the Kubernetes Cluster, along with any features in AKS or AKS-Engine that you decide to implement. Instead of worrying about obtaining official Microsoft Support for a Kubernetes Cluster in Azure, you are better off determining how you and your team can best manage and support the Kubernetes Cluster, and the applications running in it, by yourselves.

</br>

## Things to Consider

