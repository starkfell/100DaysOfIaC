# Day 54 - What are all the ways to validate an ARM template?

There are few things more irritating than a carefully crafted ARM deployment that fails when you deploy it to a live Azure subscription, so in this installment, we are going to quickly review the options available for validating your ARM templates to ensure they will work.

In this article:

[Native Solutions](#native-solutions) </br>
[Community Solutions](#community-solutions) </br>
[Coming Soon: what-if for ARM](#coming-soon-what-if-for-arm) </br>
[Avoid This](#avoid-this) </br>

## Native Options

There are a couple of native options for validating, but some go deeper than others.

### Validate Mode in CI Build Pipelines

The **Azure Resource Group Deployment** is a native task in Azure DevOps designed to deploy an ARM template to a new or existing resource group we specify, in the Azure subscription we choose. However, as you can see in Figure 1 we have specified "Deployment mode: Validation only", which means a resource group will be created and the ARM template syntax will be validated, but not actually deployed. It's important to note that this simple approach confirms your ARM template is syntactically correct, *but does not verify it is actually deployable in your Azure subscription*. This is demonstrated in [Day 12](https://raw.githubusercontent.com/starkfell/100DaysOfIaC/master/articles/day.12.contin.integration.md) of the 100 Days of IaC series.

![001](https://github.com/starkfell/100DaysOfIaC/blob/master/images/day54/figure1.png)
**Figure 1.** Azure Resource Group Deployment task settings in Azure Pipelines

### PowerShell in Azure DevOps pipelines

Microsoft has moved to using PowerShell scripts in Azure DevOps pipelines, and even provide a sample pipeline you can import at ["Setting Up Your Own CI/CD Pipeline in Azure DevOps"](https://github.com/Azure/azure-quickstart-templates/tree/master/test/pipeline). The pipeline references around a dozen PowerShell scripts used to validate various aspects of the deployment, which you can find in the following folder of Azure QuickStart repo: https://github.com/Azure/azure-quickstart-templates/tree/master/test/ci-scripts. 

### PowerShell Cmdlets

There are two PowerShell cmdlets available in the **Az.Resources** module for validating ARM templates:

- **Test-AzResourceGroupDeployment**. The Test-AzResourceGroupDeployment cmdlet determines whether an Azure resource group deployment template and its parameter values are valid.
- **Test-AzDeployment**. The Test-AzDeployment cmdlet determines whether a deployment template and its parameter values are valid.

**What's the difference between the two?**

Basically, one targets a specific *resource group*, and another targets *the current subscription scope*, but there's a bit more to it. I've described some of the differences a bit further below

**EXAMPLE: Test-AzResourceGroupDeployment**

This command tests a deployment in the given **resource group** using the an in-memory hashtable created from the given template file and a parameter file. In addition to what you see here, you could specify 
- the `-ResourceGroup` parameter -
- `-Mode` parameter, which can be *complete* or *incremental*.
- Also a couple of `-Rollback*` parameter options

``` PowerShell
# Read the ARM template file 
$TemplateFileText = [System.IO.File]::ReadAllText("D:\Azure\Templates\EngineeringSite.json")
$TemplateObject = ConvertFrom-Json $TemplateFileText -AsHashtable
# Read the parameter file
Test-AzResourceGroupDeployment -ResourceGroupName "ContosoEngineering" `
-TemplateObject $TemplateObject -TemplateParameterFile "D:\Azure\Templates\EngSiteParams.json"
```

**EXAMPLE: Test-AzDeployment**

 This command tests a deployment at **the current subscription scope** using the given template file and parameters file. We can also specify the location to test viability in the subscription based on the region targeted.

``` PowerShell
Test-AzDeployment -Location "West US" -TemplateFile "D:\Azure\Templates\EngineeringSite.json" `
-TemplateParameterFile "D:\Azure\Templates\EngSiteParms.json"
```

**Missing these cmdlets?** Install the Az.Resources PowerShell module:

`install-module Az.Resources -Force`

## Community Solutions

There are a couple of community-based solutions for validating your ARM templates, which are described below.

### Pester Testing ARM Templates

This less common, but very thorough approach (and not for the faint-of-heart), from Microsoft MVP, [the benevolent Tao Yang](https://blog.tyang.org/2018/09/12/pester-test-your-arm-template-in-azure-devops-ci-pipelines/), is great if you want or need to go the extra mile in ensuring no unauthorized changes are made to your deployment templates. To quote Tao's detailed post on the solution:

*Now can you ensure the ARM template you are deploying only deploys the resources that you intended to deploy. In other words, if someone has gone rogue or mistakenly modified the template, how can you make sure it does not deploy resources that’s not supposed to be deployed (i.e. a wide open VNet without NSG rules).*

Check out the full walkthrough and source code in ["Pester Test Your ARM Template in Azure DevOps CI Pipelines"](https://blog.tyang.org/2018/09/12/pester-test-your-arm-template-in-azure-devops-ci-pipelines/)

### Test-ArmDeployDetailed (from Barbara 4bes)

This one wraps the native `Test-AzResourceGroupDeployment` and parses the HTTP output. While it's reasonably well-explained on the solutions Git repo and this blog post, but by the stars and follows on Github it doesn't seem to have picked up much of a following, though this is not necessarily a reflection on quality. Barbara's solution is definitely worth a look to see if it resonates with you at https://github.com/Ba4bes/Test-ArmDeployDetailed.

## Coming Soon: what-if for ARM

The long-awaited solution for ARM validation is the what-if functionality now in Preview, provides the what-if operation to let you see how resources will change if you deploy the template. The what-if operation doesn't make any changes to existing resources. Instead, it predicts the changes if the specified template is deployed. It will test for six(6) different kinds of changes: **Create**, **Delete**, **Ignore**, **NoChange**, **Modify**, and **Deploy**.

This works both for resource group based deployments and REST-based deployments, which means you should be able test your management group deployments executed via REST API. We will unpack the what-if preview in a later post here in the **100 Days of IaC in Azure** series.

Get the details and sign up for the Preview at ["Resource Manager template deployment what-if operation (Preview)"](https://docs.microsoft.com/en-us/azure/azure-resource-manager/template-deploy-what-if)

## Avoid This

The Azure-Arm-Validator, described by the Microsoft author as "A tiny server which will validate Azure Resource Manager scripts". It requires some configuration, uses a MongoDB backend, and has been succeeded by the native validation now available in native options like [Test-AzResourceGroupDeployment](https://docs.microsoft.com/en-us/powershell/module/az.resources/test-azresourcegroupdeployment?view=azps-3.0.0) and the pipeline-integrated PowerShell described above. Bottom line is probably nobody should be using it anymore.

## Conclusion

ARM template validation is a topic with many facets, and a number of options to meet a variety of deployment scenarios. We hope this post jump starts your efforts in implementing a validation strategy for your ARM deployments. We have 46 days left, so don't hesitate to reach out if you have topics you'd like us to cover.
