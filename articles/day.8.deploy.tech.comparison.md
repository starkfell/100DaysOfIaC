
# Day 8 - Comparing Native Microsoft Options and Terraform for IaC Deployment

Terraform is deployment technology for Infrastructure-as-Code that is enjoying a lot of buzz right now, so we wanted to touch on a common question we hear:

**Should we use Terraform instead of ARM?**

Terraform is a great option for Infrastructure-as-Code, and we don't want to discourage you from adoption, but we do want you to go into this decision with the right criteria in mind. In this article, we'll touch on some considerations that will enable you to answer this question for yourself.

We'll start by comparing Terraform to the native Microsoft options of PowerShell, Azure CLI, and ARM on the criteria of **declarative** and **idempotent**. As shown in Figure 1, Terraform, like ARM, is both declarative and idempotent.

![IaC deployment tech comparison](https://github.com/starkfell/100DaysOfIaC/blob/master/images/day8/fig1-deploy-tech-compare.png)

**Figure 1**. Characteristics of common Azure IaC deployment options

> **NOTE:** While Azure DevOps supports 'any cloud, any language', we're going to focus on these core four options for purposes of this discussion. Other languages, such as Python, are supported, but are not idempotent and declarative, so we'll touch on those in later installments.

If you are unclear on what *declarative* and *idempotent* mean, quickly revisit [Day 7 - Using Azure CLI in Your Everyday IaC Strategy](https://github.com/starkfell/100DaysOfIaC/blob/master/articles/day.7.using.azure.cli.in.your.everyday.iac.strategy.md)

## Advantages of Terraform

The #1 advantage of Terraform is that it supports multiple cloud platforms, like Azure, Amazon, and Google Cloud Platform. So, if your org uses multiple cloud platforms, Terraform can be a great choice, because it provides a single declarative, idempotent language for describing your deployments across multiple platforms.

Terraform does claim an advantage to JSON in terms of human readability, but at the cost of a custom (non-native, 3rd party). Because Azure DevOps supports any cloud, any language, you will find native Terraform tasks for Azure Pipelines.

## Disadvantages of Terraform

While Terraform is getting a lot of buzz right now, and may have a place in your IaC toolkit, it's not a solution for every problem. There are some definite disadvantages of Terraform that are worth considering.

**Delay in support for latest Azure features**. Sometimes it takes Terraform a while to support the latest Azure features. If memory serves, last year the delay was support Azure Key Vault secrets, this year the delay is Azure Front Door (see [this request for Azure Front Door support](https://github.com/terraform-providers/terraform-provider-azurerm/issues/3186) opened in April, closed 9 days ago). So, if you need access to the latest and greatest Microsoft features, this is something to consider. 

While you can next PowerShell, Azure CLI and other languages within Terraform to bridge these gaps, it kind of defeats the purpose.

**Fewer examples**. Terraform will have fewer examples for any given Azure scenario than you will find with native Microsoft deployment options. If you thrive on examples, this may occasionally prove to be a challenge.

**In-house skills**. Within your organization, it's quite likely you have colleagues who know PowerShell, and if your company uses Azure, you'll likely have Dev or Ops team members with ARM and Azure CLI experience. With Terraform, in our experience, this will almost certainly not be the case, at least initially.

Bottom line, even though Terraform is declarative and idempotent, your team has to learn a new language: [**Hashicorp Configuration Language**](https://www.terraform.io/docs/configuration-0-11/syntax.html). I've heard the comment from multiple DevOps pros that they feel arm was and just as easy (or easier) to learn and manage in their opinion.

**You will still write code for each cloud**. Each cloud provider has unique services and service characteristics, so Terraform does not give you a 'write once, deploy to any cloud experience'. For example, if you're deploying a managed Kubernetes cluster to Azure (AKS), another in Amazon (EKS), you will still have to write separate deployment scripts.

## Conclusion

If your organization is a user of multiple cloud platforms, Terraform may be a great fit. If your org is new to Azure and does not have a team with strong skills in any native Microsoft deployment options, this might be the perfect time to consider Terraform adoption. However, if you are 'all in' for Azure, and working with bleeding edge features, you may want to think twice before investing heavily in Terraform as a deployment strategy.
