# Day 52 - DevSecOps tooling and practices for Azure DevOps (part 1)

DevSecOps applies to Infrastructure-as-Code, especially when we weave outside ARM templates into containers, scripts, compiled languages, and external sources. In this installment, we'll touch on some of the DevSecOps tooling available to help get your org started down the path of ensuring code quality and security in your CI/CD process. In later installments, we'll crack some of these open and look a bit closer at how they work.

In this article:

[Static Code Analysis in CI Build Pipeline](#static-code-analysis-in-ci-build-pipeline) </br>
[Secure Code Validation in the Release Process](#secure-code-validation-in-the-release-process) </br>
[Security Code Analysis Extension](#security-code-analysis-extension) </br>
[Microsoft Security Code Analysis tool set](#microsoft-security-code-analysis-tool-set) </br>
[Scanning your Docker container images](#scanning-your-docker-container-images) </br>
[Strategy Recap](#strategy-recap) </br>

## Static Code Analysis in CI Build Pipeline
CI builds should run static code analysis tests to ensure that the code is following all rules for both maintenance and security. Several tools can be used for this:

- **Visual Studio Code Analysis and Roslyn Security Analyzers**. These analyzers analyze your code for style, quality and maintainability, and design.Microsoft also created a set of analyzers called [**Microsoft.CodeAnalysis.FxCopAnalyzers**](https://docs.microsoft.com/visualstudio/code-quality/install-fxcop-analyzers) that contains the most important "FxCop" rules from static code analysis, converted to Roslyn analyzers. These analyzers check your code for security, performance, and design issues, among others.
- **Checkmarx** - A Static Application Security Testing (SAST) tool
- **BinSkim** - A binary static analysis tool that provides security and correctness results for Windows portable executables

## Secure Code Validation in the Release Process

Once your code quality is verified, and the application is deployed to a pre-production environment like Dev, Test, or QA/Stage, the process should verify that there are not any security vulnerabilities in the running application. This can be accomplished by executing automated penetration tests against the running application to scan it for vulnerabilities. There are different levels of tests that are categorized into passive tests and active tests. Passive tests are great in scenarios when you need quick run time. Active scans can get pretty involved in the attack techniques they simulate, and are best left for execution off hours.

One tool to consider for penetration testing is **OWASP ZAP**. [OWASP](https://www.owasp.org/) is a global not-for-profit organization dedicated to helping improve the quality of software. ZAP is a free penetration testing tool for beginners to professionals. You can read up on how to set it up in the [**OWASP ZAP VSTS extension**](https://github.com/deliveron/owasp-zap-vsts-extension) repo.

## Secure DevOps Kit for Azure

The Secure DevOps Kit for Azure (AzSK) was created by the Core Services Engineering & Operations (CSEO) division at Microsoft, to help accelerate Microsoft IT's adoption of Azure. Microsoft has shared AzSK and its documentation with the community to provide guidance for rapidly scanning, deploying and operationalizing cloud resources, across the different stages of DevOps, while maintaining controls on security and governance.

Bear in mind AzSK is not an official Microsoft product, but rather an attempt to share Microsoft CSEO's best practices with the community. You can find more info and a walkthrough on installing and running the AzSK PowerShell module against your Azure subscription at https://azsk.azurewebsites.net/.

# Security Code Analysis Extension

The most recent DevSecOps offering from Microsoft is the **Security Code Analysis Extension**, which is a collection of tasks for the Azure DevOps Services platform. These tasks automatically download and run secure development tools in the build pipeline. To use this extension, you'll simply add some additional tasks to your pipeline. The objective with this offering is to hide some of the complexity of running static code analysis tools. This toolkit also offers advanced testing features like fuzz testing, an anti-malware scanner, a credential scanner, and some language-specific analyzers for C# and TypeScript.

To enforce quality, you can configure the extension to break builds when it finds issues. The tools are self-maintaining (always up-to-date), so no worries there either.

You can read more on the Security Code Analysis Extension offering at https://secdevtools.azurewebsites.net/


## Scanning your Docker container images

Because your Docker container images will often be based on other base container images from external sources, it's important to ensure they are free of any malicious code. There are several options that will scan the container images directly in your Azure Container Registry, though most will scan other container registries as well. In the free tools category, **OWASP ZAP** (mentioned earlier) is an option. Third parties that offer container image scanning (at an additional cost) include **Twistlock**, **Aqua**, **Sysdig**, and **Rapid7**. Microsoft has mentioned publicly they something in the works in this area as well.


## Strategy Recap

To recap a few key items mentioned related to DevSecOps in Azure DevOps:

- CI builds should run static code analysis tests
- Penetration testing in the Dev/Test environments
  - Passive tests at minimum, active tests scheduled for off-hours.
- Scan container images in your container registries (ACR or other)
- Explore the advanced options in the Security Code Analysis Extension (mentioned above) to beef up code security testing in your pipelines.

## Conclusion

This installment should provide some food for thought and additional reading to get you headed down the path of DevSecOps integration. We'll circle back in later installments to explore some of the Microsoft-sourced options.
