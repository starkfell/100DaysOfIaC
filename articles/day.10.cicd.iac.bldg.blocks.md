# Day 10 - Building Blocks of CICD Strategy for IaC in Azure DevOps

In the world of DevOps, CI/CD, or continuous integration (CI) and continuous delivery (CD), can be described most simply as the process of automating build, testing, and deployment of applications and the virtual infrastructure that supports it (the Infrastructure-as-Code).

Today, we're going to cover some foundational components before we dive into actually setting up build and release automation in the week or so.

In this article:

[Continuous Integration](#continuous-integration) <br />
[Continuous Deployment](#continuous-deployment) <br />
[Automation Controls](#automation-controls) <br />
[Code Branching Strategy](#code-branching-strategy) <br />
[Build and Release Pipelines](#build-and-release-pipelines) <br />
[Next Steps](#next-steps) <br />

Let's start by breaking down CI/CD, and how it's implemented in Azure DevOps. While we think of this as a foundational concept of DevOps, IaC strategy mirrors, ingrates with, and supports application development. IaC will implement these concepts as well.

## Continuous Integration

Continuous Integration (CI) is a development practice that requires developers to integrate code into a shared repository, often multiple times a day. several times a day. Committing code to the git repo triggers an automated build system, allowing teams to detect problems early. In Azure DevOps, you implement CI in a **build pipeline** in Azure Pipelines.

## Continuous Deployment

Continuous deployment is the next step of the CI/CD process. Every change that passes our automated tests is deployed to production *automatically*. Continuous deployment should be the goal of most companies that are not constrained by regulatory constraints, though this takes commitment to the process. CD is implemented in a **release pipeline** in Azure Pipelines.

## Automation Controls
Automated testing, deployment, and release is the goal, but we need to have checks and balances to ensure code that is deployed to production is actually ready for production. Azure Pipelines includes two important features that enable us to ensure we never deploy code to Test or Prod environments before it is tested and ready.

**Quality gates**. At the most basic level, we can set a minimum bar of "build must succeed" or "previous stage must succeed" before automated deployment proceeds.

**Approval gates**. If you look ahead to figure 1, you'll notice that we have an *approval gate* on deployment for the Prod environment. This means automated deployment proceeds only after a human hits the approval button. This may come after user acceptance testing has been deemed successful, the change board approves, etc.

## Code Branching Strategy

You should not be developing directly in Master. You need a code branching strategy. One of the most common code branching strategies for Git is [Gitflow](https://datasift.github.io/gitflow/IntroducingGitFlow.html). However, for Infrastructure-as-Code (IaC), Gitflow can be overkill, and a bit complex for the average IT operations engineer to manage.

What is illustrated in Figure 1 below is a scaled down, environment-based code branching strategy for IaC. This is not a new strategy we hatched today, but a strategy we have seen work reasonably well as a starting point for organizations beginning their IaC journey.

- There is a **Develop** code branch to house your IaC scripts, ARM templates, and other code. When deployment artifacts are developed and tested, they can be promoted to the **Master** branch.

- When code is committed to the Master branch, it triggers validation before deployment to the **TEST** environment.

- Once testing is complete and ready for production, there is an *approval gate* where someone must approve the deployment to the **PROD** environment.

![Code braches for our IaC scenario](fig1.code.branching.png)

**Figure 1**. Code branching for IaC (example)

## Build and Release Pipelines

The process of validating deployment artifacts, like ARM templates, should be completed before code is deployed to the TEST environment, if possible. 

![Build and release pipelines for CICD](fig2.build.release.pipelines.png)

**Figure 2**. Build and Release Pipelines for CI/CD

## Next Steps

We'll get hands-on with code branching, automating validation of your code artifacts, and configuring build and release pipelines over the next few days. To ready yourself, get VS Code installed with the extensions we mentioned earlier in the series, and sign up for an Azure DevOps instance if you don't have one yet.
