# Day 7 - Using Azure CLI in Your Everyday IaC Strategy

While PowerShell is everywhere, Azure CLI is a deployment option for Infrastructure-as-Code (IaC) we see implemented much less often. We're going to look at a few reasons why Azure CLI is a great option, and if you are not familiar, how you can get up and rolling, learning Azure CLI and Bash (shell scripting) so you can leverage Azure CLI in your IaC.

And if you have open source developers, working in Java, Bash, Linux, and similar technologies, this is a great way to ease them into Azure DevOps as a platform for CI/CD without forcing them to learn ARM templates on their first day.

This is not an argument against using ARM, but a five-minute intro to show you why Azure CLI is much more powerful and easy to use than most give it credit for and deserves a place in your IaC arsenal.

> **NOTE:** This article applies to both Linux and Windows.

***
SPONSOR: Need to stop and start your development VMs on a schedule? The Azure Resource Scheduler let's you schedule up to 10 Azure VMs for FREE! Learn more [HERE](https://azuremarketplace.microsoft.com/en-us/marketplace/apps/lumagatena.resourcescheduler?tab=Overview)
***

In this installment:

[Azure CLI is Idempotent!](#azure-cli-is-idempotent)<br />
[But Azure CLI is not declarative!](#but-azure-cli-is-not-declarative)<br />
[TIP: Do-it-Yourself Declarative Deployment for Azure CLI](#tip-do-it-yourself-declarative-deployment-for-azure-cli)<br />
[Getting Help in Azure CLI](#getting-help-in-azure-cli)<br />
[The Azure CLI Tools Extension for VS Code](#the-azure-cli-tools-extension-for-vs-code)<br />
[Don't know Shell scripting?](#don't-know-shell-scripting)<br />

## Azure CLI is Idempotent!

**Idempotency** is one of the two most important factors in provisioning resources as part of an Infrastructure-as-Code strategy, in my opinion.  Idempotent means you can make the same call repeatedly, and the result is always the same, always producing the same result. If I run a script that aims to deploy a single VM, it will always ensure a single VM is deployed. You won’t get an error that the resource already exists, and you will never get a second VM that you didn't want.

One little-known fact about Azure CLI is that the create and update commands are idempotent, and the documentation even confirms this!

> **NOTE:** PowerShell commands are generally not idempotent.

## But Azure CLI is not declarative!

One of the detractors against the argument for is that the Azure CLI is not **declarative**. Declarative programming (for declarative deployment) means writing code to describe *what* the program should do rather than *how* it should do it. Actually, Azure CLI is declarative for resource creation and update, but not for the sequence of provisioning. We'll show you a trick for bridging this gap so you can tap into the advantages of Azure CLI over ARM Templates.

Advantages you ask? Azure CLI offers several. Azure CLI is easy to maintain because you explicitly define the deployment. It easy to read, and we can easily implement logging that makes troubleshooting quite simple (which is so beautiful it deserves it's own installment). And with Azure CLI, it's easier to take the output from one resource and use it in another in your release pipeline.

## TIP: Do-it-Yourself Declarative Deployment for Azure CLI

Here's a great way to address declarative deployment sequence in deploying Infrastructure-as-Code with Azure Pipelines, which is part of Azure DevOps.

> **NOTE:** Azure Pipelines is a topic we'll cover at greater depth in the near future.

In a release pipeline, you can specify deployment stages (the boxes in Figure 1), and establish **pre-deployment conditions**. Pre-deployment conditions can include only allowing the next stage to deploy if the previous stage is successful, enabling you to reliably control the deployment sequence!

![Azure Release Pipeline](/images/day7/azdo-release-pipeline.png)
**Figure 1**. Multi-Stage Azure Release Pipeline

<br />

Azure Pipelines also includes a native Bash task (shown in Figure 2) that makes running reliable Azure CLI scripts not only achievable, but relatively easy. You can call a Shell script containing Azure CLI from your repo, passing parameter values as necessary, or select the the inline option and type Azure CLI snippets directly into the window provided.

![AZDO Bash Task](/images/day7/azdo-bash-task.png)
**Figure 2**. Bash Task Azure Release Pipeline

<br />

In fact, what you see in Figure 1 are the first two stages of an eight stage release pipeline, which deploys a complex Azure Kubernetes environment, and is built entirely on Azure CLI using deployment stages and the Bash task! This pipeline is idempotent, declarative (through the staged approach), and *very* reliable.

# Getting Help in Azure CLI 

With Azure CLI, I can type as much of a command and ask for help anytime, simply by using the `--help` command. For example:

`az --help`

`az vm --help`

Best of all, unlike PowerShell, Azure CLI NEVER asks you if you want to download help content so you can get help, it just gives you help! Brilliant!

## The Azure CLI Tools Extension for VS Code

The Azure CLI Tools extension for VS Code that elevates the scripting experience in VS Code. You can add this extension directly within VS Code or from the Visual Studio Marketplace [HERE](https://marketplace.visualstudio.com/items?itemName=ms-vscode.azurecli)

Just save your script-in-progress with an **.azcli** extension in VS Code and you get these features *instantly*:

- IntelliSense for Azure CLI commands and their arguments.
- Snippets for commands, inserting required arguments automatically.
- Run the current command in the integrated terminal.
- Run the current command and show its output in a side-by-side editor.
- Show documentation on mouse hover.
- Display current subscription and defaults in status bar.

## Don't know Shell scripting?

Azure CLI is a breeze if you are familiar with shell scripting (Bash). If you are not, you can learn the basics in a single Friday afternoon for FREE. There is a fantastic series of step-by-step tutorials that will get you familiar with Bash and shell scripting concepts at https://www.shellscript.sh/.

You will also find Azure CLI examples throughout Microsoft Docs, as well as within this series, with more to come!
