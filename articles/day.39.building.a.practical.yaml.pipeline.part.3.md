# Day 39 - Practical Guide for YAML Build Pipelines in Azure DevOps - Part 3

***Part 1** of this series can be found **[here](./day.35.building.a.practical.yaml.pipeline.part.1.md)**.*</br>
***Part 2** of this series can be found **[here](./day.38.building.a.practical.yaml.pipeline.part.2.md)**.*</br>

</br>

Today, we are going over some Infrastructure as Code related things to consider when building and managing your Build Pipelines in Azure DevOps.

## Pick a Toolset

So you've been reading our 100 Days of IaC Series, along with a lot of other Microsoft Azure DevOps related articles and you are overwhelmed with the sheer amount of options that are available to use. Do I want to use bash or PowerShell? Do I want to use ARM Templates? Do I want to use Terraform? Do I want to use python and Ansible? The choices and combinations available to you are practically endless. So what should you do?

### Pick a toolset that plays to the skillset of your Team

If 90% of your Team has been using GUI based management systems and have just started using PowerShell, it would behoove you to start with using PowerShell related tasks available in Build Pipelines along with the **classic editor**. I wouldn't recommend sticking long-term with the **classic editor** simply because you have been tracking and control when your Build Pipelines are configured in YAML and tied to a Git repository.

If 90% of your Team has a strong Linux background and is comfortable in with bash and python, then stick with the Azure CLI and bash/python scripting.

If you have an edge case scenario that deviates from the rest of the primary tools that you have in place because it just works better, then so be it. You may find that there's a particular ARM Template or Terraform Template that provides exactly what you need so go ahead and integrated into your Build Pipeline(s).

## Controlling Code Sprawl

In order to control code spawl

## Bake in Idempotence

Anything and everything that you put into your Build Pipeline should be idempotent, Period!

What is idempotence and why is it important you ask?

*Idempotence is running a set of operations or tasks and always achieving the same results irrespective of how many times they are executed.*



## Change is not only inevitable, it is also necessary

So you've tried the to control all of your existing IaC Coding as bash or PowerShell Scripts but you aren't able to


```text
option 1 - Build GRAV CMS from original Dockerfile
option 2 - cleanup existing scripts for better readability of output in task logs
option 3 - turn everything into scripts that are files and not inline. (conversion option)
```