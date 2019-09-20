# Day 12: Intro to Continuous Integration in Azure Pipelines

In [Day 10](https://github.com/starkfell/100DaysOfIaC/blob/master/articles/day.10.cicd.iac.bldg.blocks.md#automation-controls), we discussed some CI/CD concepts, and today we're getting into the details, digging deeper into continuous integration (CI).  We'll break down the information introduced in today's installment in the days to come. In time, all questions will be answered.

We're going to show you an example of a CI build pipeline that performs the following actions (pictured in Figure 1):

  [Step 1: Create Build Pipeline & Select Git repo](#step-1-create-build-pipeline-and-select-git-repo) <br />
  [Step 2: Azure Resource Group Deployment](#step-2-azure-resource-group-deployment) <br />
  [Step 3: Delete Resource Group if it is empty](#step-3-delete-resource-group-if-it-is-empty) <br />
  [Step 4: Publish build artifacts *](#step-4-publish-build-artifacts) <br />
  [Step 5: Deploy to Test](#step-5-deploy-to-test) <br />
  [Next Steps](#next-steps) <br />

\* At this stage, we have an ARM template ready to deploy to a Test environment.

![Build Pipeline in Azure Pipelines](https://github.com/starkfell/100DaysOfIaC/blob/master/images/day12/figure1.png)

**Figure 1**. Elements of our build pipeline in Azure Pipelines

We can leave the **Run on agent** task, shown in Figure 1, with its default values, as we need a Windows build agent for ARM deployment.

We'll create the build pipeline using the classic editor, rather than YAML, because it is a more complete and user-friendly experience than YAML today. There is a time and place for using the YAML pipeline authoring experience, which we will discuss later in the series.

## Step 1: Create Build Pipeline and Select Git repo

To launch the classic editor, click on Azure Pipelines, Builds, and at the bottom of the Builds screen click "**Use the classic editor to create a pipeline without YAML**".

 When we create the Build Pipeline, we will select the "**Continuous Integration**" option. This will trigger build and publish an artifact (our updated ARM template) every time we perform a check-in to our Git repo (in Azure Repos).This enables the 'build on commit' strategy for CI we discussed in Day 10.

![Choose the Git repo that hosts the ARM template](https://github.com/starkfell/100DaysOfIaC/blob/master/images/day12/figure2.png)

**Figure 2**. Select the Git repo that will trigger CI process.

## Step 2: Azure Resource Group Deployment

This is a native task in Azure DevOps designed to deploy an ARM template to a new or existing resource group we specify, in the Azure subscription we choose. However, as you can see in Figure 3 we have specified "**Deployment mode: Validation only**", which means a resource group will be created and the ARM template syntax will be validated, but not actually deployed.

**A note on ARM template validation**. It's important to note that this simple approach confirms your ARM template is syntactically correct, but does not verify it is actually deployable in your Azure subscription. For example, you might have an Azure policy with specific naming or tagging requirements that blocks deployment. We will cover other custom, more in-depth validation methods in a future installment.

![Resource Group Deployment in Azure Pipelines](https://github.com/starkfell/100DaysOfIaC/blob/master/images/day12/figure3.png)

**Figure 3**. Azure Resource Group Deployment task settings in Azure Pipelines

## Step 3: Delete Resource Group if it is empty

The template validation step creates an Azure resource group in the validation process that is ultimately empty. "Delete Resource Group" is a custom task developed by a community author (Marco Mansi) and is available for download from the Visual Studio Marketplace [HERE](https://marketplace.visualstudio.com/items?itemName=marcomansi.MarcoMansi-Xpirit-Vsts-DeleteResourceGroupIfEmpty). This task reliably verifies the  resource group is empty before deleting it.

![Delete Resource Group if Empty task in Azure Pipelines](https://github.com/starkfell/100DaysOfIaC/blob/master/images/day12/figure4.png)

**Figure 4**. Delete Resource Group if Empty task settings in Azure Pipelines

## Step 4: Publish build artifacts

Once the template has been validated, the next step is to produce our build artifact (the ARM template, in this case). We do this with the **Publish Build Artifacts** task, as shown in Figure 5.

![Publish build artifacts task in Azure Pipelines](https://github.com/starkfell/100DaysOfIaC/blob/master/images/day12/figure5.png)

**Figure 5**. Publish build artifacts task settings in Azure Pipelines

## Step 5: Deploy to Test

With the deployment artifact published and the build successful, the [quality gate](https://github.com/starkfell/100DaysOfIaC/blob/master/articles/day.10.cicd.iac.bldg.blocks.md#automation-controls) is met, and deployment to our Test environment is triggered. Whatever ARM template we attempted to deploy should now be deployed in our target test environment.

## Next Steps

Next week, we'll talk through the beginning of this process, working with Git, and then provide the first of a few functional ARM templates to deploy in your environment so you can see the CI process through from end-to-end!
