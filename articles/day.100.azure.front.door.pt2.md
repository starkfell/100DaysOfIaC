# Day 100 - Azure Front Door (Part 2)

Today, the FINAL DAY of the "100 Days of Infrastructure-as-Code" series, we're going to talk through details of Azure Front Door (AFD) related to routing options, but also step back and talk about where AFD fits in your Azure load balancing options. We covered some AFD basics yesterday, so if you haven't read [Day 99](https://github.com/starkfell/100DaysOfIaC/blob/master/articles/day.99.azure.front.door.pt1.md) yet, take five minutes and give it a quick read.

Today, we're also going to touch on a few additional concepts you'll need to get the gist of AFD configuration quickly, and give you a single click to an easy AFD test deployment.

In this article:

[Azure Global vs Regional Services](#azure-global-vs-regional-services) </br>
[Enabling HTTPS in Front Door](#enabling-https-in-front-door) </br>
[Backends and backend pools in in AFD](#backends-and-backend-pools-in-afd) </br>
[Other important AFD settings (and sample ARM templates)](#other-important-afd-settings-and-sample-arm-templates) </br>
[Quick AFD ARM Deployment](#quick-afd-arm-deployment) </br>
[Next Steps](#next-steps) </br>

## Azure Global vs Regional Services

It's worth repeating that Azure Front Door (AFD) is a **global service**, which is a service that spans multiple Azure regions. A regional service is something that must be provisioned in each Azure region where you need the functionality

Before AFD, [Azure Traffic Manager](https://docs.microsoft.com/en-us/azure/traffic-manager/traffic-manager-overview) was the go-to global load balancing solution, which is based on DNS. Traffic Manager improves application responsiveness by directing traffic to the endpoint with the lowest network latency for the client, but does not leverage Microsoft's global network to further optimize performance the way AFD does.

[Azure Application Gateway](https://azure.microsoft.com/en-us/services/application-gateway/) (is a Layer 7 HTTP reverse proxy with optional firewall and SSL offloading) and [Azure Load Balancer](https://docs.microsoft.com/en-us/azure/load-balancer/load-balancer-overview) (layer 4 load balancing of any UDP or TCP service, supporting internal and public IP) are both examples of **regional services**.

If you're not up-to-speed on your global vs regional options, you can dig a little deeper [HERE](https://docs.microsoft.com/en-us/azure/frontdoor/front-door-lb-with-azure-app-delivery-suite)

## Enabling HTTPS in Front Door

Perhaps the most common scenario I encounter with Azure Front Door is enabling routing for web application endpoints in multiple Azure regions. In a addition to an ARM sample, there are a couple of things you'll need to be aware of.

When you enable HTTPS for an Azure Front Door Service with a custom domain, you **must** use an allowed certificate authority (CA) to create your SSL certificate. If you try to use a certification authority not on the list, or a self-signed certificate, your request will be rejected. You can find a list of the approved providers at
["Allowed certificate authorities for enabling custom HTTPS on Azure Front Door Service"](https://docs.microsoft.com/en-us/azure/frontdoor/front-door-troubleshoot-allowed-ca).

**IMPORTANT**: Currently, you cannot setup custom domain AFD managed certificates via ARM templates.  Currently, you would have to work around this with Azure CLI in your release pipelines. Microsoft is watching this issue on User Voice, but has not yet approved it for the backlog. You can upvote [HERE](https://feedback.azure.com/forums/217313-networking/suggestions/37886764-enable-azure-front-door-managed-certificates-in-ar).

You can find the sample ARM template at ["Enabling HTTPS in Front Door"](https://github.com/Azure/azure-quickstart-templates/tree/master/201-front-door-health-probes)

## Routing in AFD

There are four options for configuring traffic routing in AFD:

- **Latency**: The latency-based routing ensures that requests are sent to the lowest latency backends acceptable within a sensitivity range. Basically, your user requests are sent to the "closest" set of backends with respect to network latency.
- **Priority**: This implements an Active/Standby or Active/Passive deployment topology, with a primary and one or more backups for failover. You can set priority values of 1 - 5 for your backends.
- **Weighted**: The 'Weighted' traffic-routing method allows you to distribute traffic evenly or to use a pre-defined weighting. A backend weighted at 50 would get twice as much traffic as another weighted at 25.
- **Session Affinity**: Much like Azure app gateways and load balancers, you can configure session affinity so subsequent requests from a user are sent to the same backend as long as the user session is still active and the chosen backend is still available.

If you want to read up on routing at greater depth, you'll find info [HERE](https://docs.microsoft.com/en-us/azure/frontdoor/front-door-backend-pool)

## Backends and backend pools in AFD

A **backend** is equal to an app's deployment instance in a region. In the AFD context, the backends would be the Azure Web App instances, each deployed in different Azure regions, as shown in **Figure 1**. Remember, your workload does NOT have to run in Azure, so it can be your on-premises datacenter or even an app instance in another cloud. 

![001](../images/day99/fig1.png)

**Figure 1**. Backends in Azure Front Door

When you specify backends in AFD, you will also specify:

- **Backend host type**. The type of resource you want to add. AFD has some auto-discovery capability for backends in app service, cloud service, or storage. For on-prem and other clouds, you will specify **Custom**.
- **Backend host type**. If you haven't selected the Custom option for backend host type, you select your backend by choosing the appropriate subscription and the corresponding backend host name.
- **Backend host header**. Requests forwarded by AFD include a host header field that the backend uses to retrieve the targeted resource. For example, a request made for www.mycontoso.us will have the host header www.mycontoso.us.
- **Priority**. See [Backends and backend pools in in AFD](#backends-and-backend-pools-in-afd) above.
- **Weight**. See [Backends and backend pools in in AFD](#backends-and-backend-pools-in-afd) above.

## Other important AFD settings (and sample ARM templates)

Here are a few other Azure Front Door ARM templates on the Microsoft Docs site as you explore AFD for your global scenarios.

You'll find an exhaustive list of Azure Front Door ARM templates [HERE](https://docs.microsoft.com/en-us/azure/frontdoor/front-door-quickstart-template-samples). Here are a few I've found especially helpful. 

[Onboard a custom domain with HTTPS (Front Door managed cert) with Front Door](https://github.com/Azure/azure-quickstart-templates/tree/master/101-front-door-custom-domain)

[Create a Front Door with multiple backends and backend pools and URL based routing](https://github.com/Azure/azure-quickstart-templates/tree/master/101-front-door-create-multiple-backends)

[Create Front Door with geo filtering](https://github.com/Azure/azure-quickstart-templates/tree/master/101-front-door-geo-filtering) - Create a Front Door that allows/blocks traffic from certain countries/regions.

[Create Front Door with Active/Standby backend configuration](https://github.com/Azure/azure-quickstart-templates/tree/master/201-front-door-priority-lb) - Creates a Front Door that demonstrates priority-based routing for Active/Standby application topology. Basically, it sends all traffic to the primary (highest-priority) backend until it becomes unavailable.

## Quick AFD ARM Deployment

A simple, 1-click, three-region AFD deployment, with a container instance resource type, is available for you by clicking the [HERE](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fplatformeng%2Fdemo-azure-front-door%2Fmaster%2Fazuredeploy.json).

## Next Steps

So, that's Day 100. We hope you have learned something new in the last 100 days of exploring Infrastructure-as-Code in Azure, Azure DevOps, and VS Code. If you have additional questions, you can open an issue here on the 100 Days repo anytime!

Thanks for your support, and best of luck on your Infrastructure-as-Code journey in Azure!