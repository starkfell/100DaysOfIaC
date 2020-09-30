# Day 39 - Practical Guide for YAML Build Pipelines in Azure DevOps - Part 3

*The other posts in this Series can be found below.*

***[Day 35 - Practical Guide for YAML Build Pipelines in Azure DevOps - Part 1](./day.35.building.a.practical.yaml.pipeline.part.1.md)***</br>
***[Day 38 - Practical Guide for YAML Build Pipelines in Azure DevOps - Part 2](./day.38.building.a.practical.yaml.pipeline.part.2.md)***</br>
***[Day 39 - Practical Guide for YAML Build Pipelines in Azure DevOps - Part 3](./day.39.building.a.practical.yaml.pipeline.part.3.md)***</br>

</br>

Today, we are covering some recommendations when using Infrastructure as Code when building and managing your Build Pipelines.

***
SPONSOR: Need to stop and start your development VMs on a schedule? The Azure Resource Scheduler let's you schedule up to 10 Azure VMs for FREE! Learn more [HERE](https://azuremarketplace.microsoft.com/en-us/marketplace/apps/lumagatena.resourcescheduler?tab=Overview)
***

## Introduction

So you've been reading our 100 Days of IaC Series, along with a other Microsoft Azure DevOps related articles and you might be overwhelmed with the plethora of options that are available in Azure DevOps. Do I want to use bash or PowerShell? Do I want to use ARM Templates? Do I want to use Terraform? Do I want to use python and Ansible? The choices and combinations available to you are practically endless. So what should you do?

## Pick Tools that Play to the Strengths of your Team

You should pick tools that play to the strengths of your team, while always keeping in mind your end goal in IaC is idempotent, declarative deployment.
If 90% of your Team uses GUI based management systems and have just started using PowerShell, it would behoove you to start with using PowerShell related tasks available in Build Pipelines along with the **classic editor**. In the long-term I would recommend moving away from the **classic editor** so you have better tracking and control with your Build Pipelines when they are configured in YAML and tied to a Git repository.

If 90% of your Team has a strong Linux background and is comfortable in with bash and python, then stick with the Azure CLI and bash/python scripting based tasks.

If you have an edge case scenario that deviates from the rest of the primary tools that you have in place because it just works better, then so be it. You may find that there's a particular ARM Template or Terraform Template that provides exactly what you need so go ahead and integrated into your Build Pipeline(s).

</br>

## Create Documentation Standards

If you've had to manage any type of application or scripts in the past; there's nothing quite as time consuming as reviewing someone's code for a few days to a week just to understand what they were doing. Reading and deciphering terse code is already difficult enough. Attempting to understand it without any comments or documentation is even worse. To that end, below are a list of suggestions to implement in your code.

* Document your Code
  * Option 1: Inline in the Script/Application
  * Option 2: Centralized location, i.e. README.md in your Repository
* Use comments that tell *why* your code works; your code already tells *how*.
* Create a Documentation Standard and stick with it

</br>

## Bake in Idempotence

Remember, as we mentioned earlier in in **[Day 8](./article/../day.8.deploy.tech.comparison.md)**:

* PowerShell is neither idempotent or declarative
* Azure CLI create commands are idempotent, but not declarative
* ARM templates are idempotent and declarative

For everyday non-production use where 99.99% reliability is not as important, having your team learn the necessary scripting skills is a win if it helps you move forward with IaC, deploying from a pipeline instead of by hand from the command line. Idempotence is running a set of operations or tasks and always achieving the same results irrespective of how many times they are executed. By ensuring that anything and everything that you put into your Build Pipeline is idempotent, you should have minimal surprises pop up in your Infrastructure that are related to the changes you made in your Build Pipeline.

</br>

## Change when and where it makes sense

So you're attempted working with thousands of lines of JSON in ARM Templates but its becoming too difficult to manage. Your team has reservations about changing over from ARM Templates to Azure PowerShell or Azure CLI based scripts. Instead of attempting to change everything over from a single tool or toolset to another;change what makes the most beneficial impact to your team with the least effort.

If you can create an idempotent Azure PowerShell or Azure CLI script that's only 100 lines long and it will replace an ARM Template that's 1000+ lines of JSON, then by all means, do so. Conversely, if you have an Azure PowerShell or Azure CLI script that isn't working as intended, but you have an ARM Template that's performing perfectly, then go with the ARM Template.

Take into account what is best for you and your team and make changes that make you more efficient and productive.

</br>

## Conclusion

In today's article we are covered some recommendations when using Infrastructure as Code when building and managing your Build Pipelines. If there's a specific scenario that you wish to be covered in future articles, please create a **[New Issue](https://github.com/starkfell/100DaysOfIaC/issues)** in the [starkfell/100DaysOfIaC](https://github.com/starkfell/100DaysOfIaC/) GitHub repository.
