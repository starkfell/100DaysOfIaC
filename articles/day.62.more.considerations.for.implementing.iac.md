# Day 62 - More considerations for implementing Infrastructure-as-Code

Today's post will cover some additional considerations to take into account when implementing Infrastructure-as-Code.

</br>

While we covered Infrastructure-as-Code Strategies and Best Practices on **[Day 16](./day.16.org.your.iac.md)**, below are some more considerations to take into account while implementing Infrastructure as Code.

In this article:

[Keep Everything in a Repository](#keep-everything-in-a-repository) </br>
[Toolset Adoption](#toolset-adoption) </br>
[Custom Tools](#custom-tools) </br>
[Document Everything](#document-everything) </br>

## Keep Everything in a Repository

While you are busy putting together solutions for deploying your Infrastructure-as-Code, you might end up finding yourself working in multiple sessions of Visual Studio Code and have 20 plus tabs open in your browser of choice while testing out your solutions in PowerShell or Azure CLI. During this process, it is completely understandable that you may forget something that you had previously worked on and had forgotten to document it in a location where someone else on your team could read about it and not make the same mistakes as you.

This is where working in a Repository where you can track all of your work can really save you. Irrespective of how small the task or problem you are working on is, make sure you are committing all of your notes and test scripts to a repository! If you want further proof of how useful this can be, feel free to browse directly in our **[articles](https://github.com/starkfell/100DaysOfIaC/tree/master/articles)** section and you'll notice some markdown documents of content that we are working on for ideas for this series that may or may not have been published.

>**NOTE:** As has already been stated in **[Day 16](./day.16.org.your.iac.md)**, we recommend *one* Git Repository.

</br>

## Toolset Adoption

It is imperative, when possible, to use tools that take advantage of the strengths of the people on your team. If your team consists of individuals that are mostly comfortable with PowerShell, then use PowerShell where possible. If your team consists of individuals that are comfortable with Linux and Bash, you are more likely going to gravitate towards the Azure CLI because of how easy it is to use with existing Linux parsing tools such as **jq**, **sed**, and **awk**.

> **NOTE:** If you are going to try and implement a solution such as Kubernetes which supports Windows, but runs on Linux, you are going to have to adopt your toolset strategy accordingly to be successful.

</br>

## Custom Tools

If there is a necessity to adopt a custom tool or solution that many individuals are not familiar with, document it! Create a process around it so that even if individuals are uncomfortable with it can still use it for deployment and troubleshooting. Markdown cheat sheets are a great example of how you can get a seasoned Windows Administrator (that is a novice in Linux) comfortable with logging into a Kubernetes Cluster and checking the logs of an application that isn't behaving as intended.

</br>

## Document Everything

Finally, irrespective of how large or small something is that you are implementing; how pointless you may feel a small change you made to your existing environment is, *document it!* For example, firewall rules are often put in place for an environment that you are setting up for the first time and require a lot of back and forth between your team and members of a large corporate Network Team. If you are having to deploy another similar environment, using IaC, and you've documented all of the firewall requirements that you had in the first place, there's no need to sift through several e-mail and chat threads to figure out what you had to do in the first place to get everything working as intended.

>**NOTE:** By keeping your documentation in Markdown format and in a Repository, your documentation becomes easily searchable from either Azure DevOps or Visual Studio Code.

</br>

## Conclusion

In today's article we discussed some additional considerations to take into account while implementing Infrastructure-as-Code. If there's a specific scenario that you wish to be covered in future articles, please create a **[New Issue](https://github.com/starkfell/100DaysOfIaC/issues)** in the [starkfell/100DaysOfIaC](https://github.com/starkfell/100DaysOfIaC/) GitHub repository.
