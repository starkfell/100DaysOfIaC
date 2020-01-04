# Day 71 - The Current State of Kubernetes in Azure

*This is the first in a series of posts about using Kubernetes in Azure.*

***[Day 71 - The Current State of Kubernetes in Azure](./day.71.the.current.state.of.k8s.in.azure.md)***</br>

</br>

In today's article we will cover the following topics.

[Deciding between AKS vs AKS-Engine](#deciding-between-aks-vs-aks-engine)</br>
[AKS Features](#aks-features)</br>
[AKS-Engine Features](#aks-engine-features)</br>
[AKS Support](#aks-support)</br>
[AKS-Engine Support](#aks-engine-support)</br>
[Things to Consider](#things-to-consider)</br>
[Conclusion](#conclusion)</br>

## Deciding between AKS vs AKS-Engine

The first thing you should probably ask before deciding between AKS and AKS-Engine is what are your requirements. Some of these may include

* Platform Requirements (Linux, Windows, or both)
* Networking Requirements
* On-premise and Cloud Storage Requirements
* Accessibility and Security Requirements

Depending on what you are trying to accomplish, you may find that certain capabilities may be available in AKS-Engine but may not be available in AKS or only in Preview. One example that we are going to go over later in this series is deploying a Private Kubernetes Cluster in Azure. This option just because available in AKS as Public Preview in December of 2019, but has been available via AKS-Engine much longer.

</br>

## AKS Features

Refer to the Official [Microsoft Documentation](https://docs.microsoft.com/en-us/azure/aks/) for the features that are currently available in AKS.

## AKS-Engine Features

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

## AKS Support

The Official documentation on Support policies for Azure Kubernetes Service can be found **[here](https://docs.microsoft.com/en-us/azure/aks/support-policies)**.

One of the big take-aways of using AKS is the following:

> AKS isn't a completely managed cluster solution. Some components, such as worker nodes, have shared responsibility, where users must help maintain the AKS cluster. User input is required, for example, to apply a worker node operating system (OS) security patch.
> The services are managed in the sense that Microsoft and the AKS team deploys, operates, and is responsible for service availability and functionality. Customers can't alter these managed components. Microsoft limits customization to ensure a consistent and scalable user experience. For a fully customizable solution, see AKS Engine.

</br>

## AKS-Engine Support

> As a free service, AKS does not offer a financially-backed service level agreement. We will strive to attain at least 99.5% availability for the Kubernetes API server. The availability of the agent nodes in your cluster is covered by the Virtual Machines SLA. Please see the Virtual Machines SLA for more details.

In other words, you are on your own in regards to any of your applications that are running on the Kubernetes Cluster, along with any features in AKS or AKS-Engine that you decide to implement. Instead of worrying about obtaining official Microsoft Support for a Kubernetes Cluster in Azure, you are better off determining how you and your team can best manage and support the Kubernetes Cluster, and the applications running in it, by yourselves.

</br>

## Things to Consider

We highly recommend that you don't make your decision on whether to use AKS or AKS-Engine based on the level of support provided, but instead on the requirements of what you are running in the Kubernetes Cluster. What we will be covering in the next few blogs posts about deploying a Private Kubernetes Cluster in Azure will hopefully alleviate any concerns you have about relying solely on support as a deciding factor when using Kubernetes in Azure.

</br>

## Conclusion

In today's article we covered the current state of Kubernetes in Azure and discussed the differences between AKS and AKS-Engine to take into account when deciding which to use. If there's a specific scenario that you wish to be covered in future articles, please create a **[New Issue](https://github.com/starkfell/100DaysOfIaC/issues)** in the [starkfell/100DaysOfIaC](https://github.com/starkfell/100DaysOfIaC/) GitHub repository.
