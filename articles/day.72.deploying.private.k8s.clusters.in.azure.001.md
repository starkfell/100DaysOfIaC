# Day 71 - Deploying a Private Kubernetes Cluster in Azure - Part 1

*This is the first in a series of posts about the current options available to you for deploying a Private Kubernetes Cluster in Azure.*

***[Day 71 - Deploying a Private Kubernetes Cluster in Azure - Part 1](./day.71.deploying.private.k8s.clusters.in.azure.001.md)***</br>

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

</br>

The [SLA](https://azure.microsoft.com/en-ca/support/legal/sla/kubernetes-service/v1_0/) for AKS is as follows as of June 2018.

> As a free service, AKS does not offer a financially-backed service level agreement. We will strive to attain at least 99.5% availability for the Kubernetes API server. The availability of the agent nodes in your cluster is covered by the Virtual Machines SLA. Please see the Virtual Machines SLA for more details.

In other words, you are on your own in regards to any of your applications that are running on the Kubernetes Cluster. Keep this in mind when deciding between AKS and AKS-Engine.
