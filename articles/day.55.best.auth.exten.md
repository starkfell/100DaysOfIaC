# Day 55 - Write better PowerShell, Azure CLI, JSON, KUSTO, Python, and YAML in VS Code

Someone asked me to share the VS Code extensions that do the most to make coding faster, easier, and less aggravating, so here they are. Whether I am writing for Infrastructure-as-Code, or a supporting function related to monitoring and security, these extensions make life better INSTANTLY. As someone who works with 5+ file types in VS Code every day, these help me my velocity significantly.

If you work with Microsoft security and monitoring tools, there is something in this post for you too!

In this article:

[Utility Extensions](#utility-extensions) </br>
[Azure CLI](#) </br>
[JSON](#json) </br>
[KUSTO](#kusto) </br>
[Python](#python) </br>
[PowerShell](#powershell) </br>

## Universal Add-ins?](#) </br>

A couple of general utility add-ins that make coding faster and easier for me.

- **Visual file type indicator**. The [Material Icon Theme](https://marketplace.visualstudio.com/items?itemName=PKief.material-icon-theme) gives you a clear, visual indicator of the file type you are working with? With 2.8 millions downloads and a user rating close to 5 stars, it's a must-have. As someone who works with many different file types in VS Code, I find this so helpful.

You can see the massive list of supported icons and languages [HERE](https://marketplace.visualstudio.com/items?itemName=PKief.material-icon-theme).

- **Beatify**. I use this to prettify the formatting of Javascript, JSON, CSS, Sass, and HTML in VS Code with a simple press of F1 thanks to [Beautify](https://marketplace.visualstudio.com/items?itemName=HookyQR.beautify). I am constantly formatting JSON, HTML, and CSS with this one.

## Azure CLI

The [Azure CLI Tools](https://marketplace.visualstudio.com/items?itemName=ms-vscode.azurecli) add-in makes writing Azure CLI a pleasure (seriously). HUGE time saver! Save your file with an **.azcli** extension and you get intellisense, inline help, snippets for command and required arguments *automatically*. If you're writing Bash scripts containing Azure CLI, this is a must-have.

[001](../images/day55/fig1.azcli.jpg)
**Figure 1**. Azure CLI Tools intellisense for parameters

## JSON

I have two must have JSON extensions to deal with my JSON scenarios.

-**ARM JSON**. For ARM templates, Microsoft's [Azure Resource Manager Tools](https://marketplace.visualstudio.com/items?itemName=msazurermtools.azurerm-vscode-tools) is the only way. Loads of features specific to aid your ARM authoring
-**JSON Tools**. For all the JSON files not ARM-related, [JSTON Tools](https://marketplace.visualstudio.com/items?itemName=eriklynd.json-tools) is a simple prettify/minify tool is good enough for most of what I need.


## KUSTO

When you're writing Kusto queries for Log Analytics, Defender ATP, or Azure Sentinel, if you save a file with a **.kql** or **.kusto** extension, the [Kusto Syntax Highlighting](https://marketplace.visualstudio.com/items?itemName=rosshamish.kuskus-kusto-syntax-highlighting) add-in gives you a visual assist with your formatting to easy spot missing quotes, etc.

[002](../images/day55/fig2.kusto.jpg)
**Figure 2**. Sample of Kusto Syntax Highlighting

## Python

Microsoft's own [Python](https://marketplace.visualstudio.com/items?itemName=ms-python.python) extension is the best game in town, and it supports Jupyter Notebook authoring for Azure Sentinel, as well as intelliSense, linting, debugging, code navigation, code formatting, Jupyter notebook support, refactoring, variable explorer, test explorer, and code snippets 

With a million+ downloads, and 4.5 star rating, and frequent updates (updated yesterday!), it's the only way to roll when you're coding in Python.

## PowerShell

The [PowerShell Preview](https://marketplace.visualstudio.com/items?itemName=ms-vscode.PowerShell-Preview) extension improves upon the original, but only if you're using PowerShell 5.1 and up. If you're using the [original](https://marketplace.visualstudio.com/items?itemName=ms-vscode.PowerShell), make sure you disable it before trying this one!

## YAML

This YAML extension from Red Hat includes Kubernetes support, one of the primary drivers of my life in YAML, but works fine for YAML pipelines for Azure Pipelines! Get YAML by Red Hat [HERE](https://marketplace.visualstudio.com/items?itemName=redhat.vscode-yaml).

## Conclusion

I hope you found an extension in my list you haven't tried before. Have a language-specific or other coding-related extension you'd like to share? Leave a comment! 