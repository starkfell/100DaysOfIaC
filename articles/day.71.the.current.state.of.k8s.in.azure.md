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
[Tooling](#tooling)</br>
[Things to Consider](#things-to-consider)</br>
[Conclusion](#conclusion)</br>

## Deciding between AKS vs AKS-Engine

The first thing you should probably ask before deciding between AKS and AKS-Engine is what are your requirements. Some of these may include

* Platform Requirements (Linux, Windows, or both)
* Networking Requirements
* On-premise and Cloud Storage Requirements
* Accessibility and Security Requirements

Depending on what you are trying to accomplish, you may find that certain capabilities may be available in AKS-Engine but may not be available in AKS or only in Preview. One example that we are going to go over later in this series is deploying a Private Kubernetes Cluster in Azure. This option just became available in AKS as Public Preview in December of 2019, but has been available via AKS-Engine much longer.

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

One of the big take-aways of support for AKS is stated below:

> AKS isn't a completely managed cluster solution. Some components, such as worker nodes, have shared responsibility, where users must help maintain the AKS cluster. User input is required, for example, to apply a worker node operating system (OS) security patch.
> The services are managed in the sense that Microsoft and the AKS team deploys, operates, and is responsible for service availability and functionality. Customers can't alter these managed components. Microsoft limits customization to ensure a consistent and scalable user experience. For a fully customizable solution, see AKS Engine.

</br>

## AKS-Engine Support

AKS-Engine is an Azure open-source project used for creating Kubernetes clusters with custom requirements and does not have any official support. At the same time, you should be aware that AKS uses the AKS-Engine internally.

</br>

## Tooling

Below are some of the tools we recommend you check out to use with Kubernetes that will work with AKS and AKS-Engine.

| Name | Description | Official Docs |
|------|-------------|---------------|
| kubectl | Used to control the Kubernetes Cluster Manager | [Documentation](https://kubernetes.io/docs/reference/kubectl/overview) |
| Helm | Package manager for Kubernetes | [Documentation](https://helm.sh/docs) |
| Helmsman | tool for automated deployment and management of Helm Charts | [GitHub](https://github.com/Praqma/helmsman) |
| Minikube | tool for running a single-node virtualized Kubernetes Cluster for development | [Getting Started](https://kubernetes.io/docs/setup/learning-environment/minikube/) |
| Kubernetes Dashboard | Web-based Kubernetes UI | [GitHub](https://github.com/kubernetes/dashboard) |
| Istio | service mesh providing traffic management, policy enforcement, and telemetry collection | [Setup](https://istio.io/docs/setup/) |
| Azure Monitor for Containers | Monitoring performance of container workloads | [Docs](https://docs.microsoft.com/en-us/azure/azure-monitor/insights/container-insights-overview) |
| Prometheus | Monitoring and Alerting Toolkit | [Docs](https://prometheus.io/docs/introduction/overview/) |
| Grafana | Analytics and Monitoring Solution | [Docs](https://grafana.com/docs/grafana/latest/) |

</br>

**kubectl** is the standard tool you will end up using if you want to manually query, manage, or deploy resources that are running in your Kubernetes Cluster.

If you have certain applications (such as NGINX Ingress Controllers) that have become standard to run in Kubernetes, but you want to customize how they are deployed without a lot of hassle, **helm** will help make this easier by setting these customizations using helm's *--set* option. Examples for NGINX Ingress controllers can be found [here](https://github.com/helm/charts/tree/master/stable/nginx-ingress).

**Helmsman** adds onto features of **helm** by allowing you to managing your different Helm releases like you would Azure Resources using Terraform or ARM.

The **Kubernetes Dashboard** is the standard Web UI for Kubernetes. A default deployment of the Kubernetes Dashboard should only provide you minimal access to view resources that are running in your Cluster.

Because of all of the features that are a part of **Istio**, We recommend that you first install **istioctl** locally on your Host machine and then deploy the manifest *demo* profile to your Cluster. Make sure you are only doing this on a development Cluster as there are over 15 Pods that will be spun up! Once you are finished determining what you want to use; teardown your previous deployment and deploy the manifest *minimal* profile and then build up from there. Be aware that although you can install Istio with helm, that method is being [deprecated](https://istio.io/docs/setup/install/helm/).

The Microsoft recommended solution of monitoring your containers in Kubernetes is to use **Azure Monitor for containers**. Enabling this feature is thoroughly documented [here](https://docs.microsoft.com/en-us/azure/azure-monitor/insights/container-insights-onboard).

Finally, **Prometheus** is typically used for ingesting and storing metrics and alerting while **Grafana** is used for visualization. There are numerous ways you can go about deploying them to work together in your Kubernetes Cluster which you can see for yourself by searching the web.

</br>

## Things to Consider

We highly recommend that you don't make your decision on whether to use AKS or AKS-Engine based on the level of support provided, but instead on the requirements of what you are running in the Kubernetes Cluster. AKS-Engine gives additionally flexibility to customize your deployment, but at the cost of cluster management which is done for you with AKS.

</br>

## Conclusion

In today's article we covered the current state of Kubernetes in Azure and discussed the differences between AKS and AKS-Engine to take into account when deciding which to use and some of the tooling available you can use to manage your cluster. If there's a specific scenario that you wish to be covered in future articles, please create a **[New Issue](https://github.com/starkfell/100DaysOfIaC/issues)** in the [starkfell/100DaysOfIaC](https://github.com/starkfell/100DaysOfIaC/) GitHub repository.
