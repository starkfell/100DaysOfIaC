# Day 17 - ARMing yourself with extensions in VS Code

In today's article we are going to quickly go over and install several ARM Template Authoring extensions that will be useful to you in future installments of the 100 Days of IaC Series.

> **NOTE:** This article was tested and written for VS Code running on Windows 10 and Ubuntu 18.04.

<br />

## Azure Resource Manager Tools

[Azure Resource Manager Tools](https://marketplace.visualstudio.com/items?itemName=msazurermtools.azurerm-vscode-tools) is your bread and butter extension for ARM Templates. It provides language support for ARM Templates and expressions along with **Go To Definition** and **Peek** support allowing you to quickly move within a large ARM Template to determine quickly how variables, parameters, and resources all relate to each other.

<br />

## Azure Resource Manager Snippets

[Azure Resource Manager Snippets](https://marketplace.visualstudio.com/items?itemName=samcogan.arm-snippets) allows you to add code snippets for creating over 20 different types of Resources in an ARM Template. Once you start typing **arm** in a JSON file, the resource snippets to choose from will appear and provide you with a basic configuration that you can customize.

<br />

## ARM Params Generator

The [ARM Params Generator](https://marketplace.visualstudio.com/items?itemName=wilfriedwoivre.arm-params-generator) extension allows you to generate a parameters file from an existing ARM Template. This can be useful in instances where you have edited an existing ARM Template and added additional parameters but aren't sure which ones are new. The ARM Params Generator can consolidate your existing parameters file and only add in missing parameters from the ARM Template.

<br />

## Azure ARM Template Helper

The primary value of the [Azure ARM Template Helper](https://marketplace.visualstudio.com/items?itemName=ed-elliott.azure-arm-template-helper) extension is that it allows you to test your ARM template functions locally which allows you to test out any included scripts without having to deploy them. Additionally, this extension can draw a graph of dependencies between resources in a template allowing you better visibility into larger ARM Templates.

<br />

## ARM Template Viewer

The name of this extension says it all. The [ARM Template Viewer](https://marketplace.visualstudio.com/items?itemName=bencoleman.armview) provides you with a graphical view of your ARM Templates utilizing Azure icons so you can get a clear view of how your resources fit together in a deployment.

<br />

## Installing the extensions from the command line

Because we like to be efficient (or lazy) we have provided you with a quick way to install the extensions previously discussed using a terminal prompt in VS Code for Windows and Linux.

> **NOTE:** After installing these extensions, you will need to close and re-open VS Code for the extensions to work properly.

<br />

### VS Code (Windows)

Run the following command from a terminal prompt in VS Code to install the extensions.

```powershell
code --install-extension msazurermtools.azurerm-vscode-tools --force `
code --install-extension samcogan.arm-snippets --force `
code --install-extension wilfriedwoivre.arm-params-generator --force `
code --install-extension ed-elliott.azure-arm-template-helper --force `
code --install-extension bencoleman.armview --force
```

<br />

### VS Code (Linux)

Run the following command from a terminal prompt in VS Code to install the extensions.

```bash
code --install-extension ms-vscode.csharp --force && \
code --install-extension msazurermtools.azurerm-vscode-tools --force && \
code --install-extension samcogan.arm-snippets --force && \
code --install-extension wilfriedwoivre.arm-params-generator --force && \
code --install-extension ed-elliott.azure-arm-template-helper --force && \
code --install-extension bencoleman.armview --force
```

<br />

> **NOTE:** You may have noticed that you can't install multiple extensions at the same time just using the *--install-extension* switch. We agree with you, it is unfortunate.

<br />

## Conclusion

In this installment, we went discussed and installed several ARM Template Authoring extensions in VS Code. Stay tuned for more installments about ARM Template Authoring in the next few days.
