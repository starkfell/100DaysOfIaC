# Day 106 - Azure Bicep: up and running in 10 minutes

Today, we're going to get you up and running on a new technology some at Microsoft have called "the future of deployment in Azure" - Azure Bicep! In fact, we'll cover the key concepts, steps to install Bicep, author and deploy a template in a little over 10 minutes!

All the resources mentioned in the video are included in this article.

In this installment:

[Video](#video) </br>
[Scripts](#scripts) </br>
[Bicep Templates](#bicep-templates) </br>
[Documentation Links](#documentation-links) </br>
[Conclusion](#conclusion) </br>

***
SPONSOR: Need to stop and start your development VMs on a schedule? The Azure Resource Scheduler let's you schedule up to 10 Azure VMs for FREE! Learn more [HERE](https://azuremarketplace.microsoft.com/en-us/marketplace/apps/lumagatena.resourcescheduler?tab=Overview)
***

# Video

You can find the video tutorial for today's installment on Youtube at https://youtu.be/B1YIA3bs5u8

## Scripts

Below are scripts run in Ryan's demo.

### Installing Bicep on Linux

```bash
# Install Bicep.
curl -Lo bicep https://github.com/Azure/bicep/releases/latest/download/bicep-linux-x64 && \
chmod +x ./bicep && \
sudo mv ./bicep /usr/local/bin/bicep
```

</br>

### Installing Bicep on Windows

```powershell
<#

A Big 'Thank You!' to Microsoft MVP Chris Pietschmann and Founder of https://build5nines.com

powershell.exe -noprofile -executionpolicy bypass -file scripts\powershell\install-bicep.ps1

#>

# Create the installation folder.
$installPath = "$env:USERPROFILE\.bicep"
$installDir = New-Item -ItemType Directory -Path $installPath -Force
$installDir.Attributes += 'Hidden'

# Fetch the latest Bicep CLI binary
(New-Object Net.WebClient).DownloadFile("https://github.com/Azure/bicep/releases/latest/download/bicep-win-x64.exe", "$installPath\bicep.exe")

# Add bicep to your PATH
$currentPath = (Get-Item -path "HKCU:\Environment" ).GetValue('Path', '', 'DoNotExpandEnvironmentNames')
if (-not $currentPath.Contains("%USERPROFILE%\.bicep")) { setx PATH ($currentPath + ";%USERPROFILE%\.bicep") }
if (-not $env:path.Contains($installPath)) { $env:path += ";$installPath" }
```

</br>

## Processing Bicep Files in PowerShell

```powershell
$BicepFiles = Get-ChildItem .\templates\ -Recurse 

foreach ($file in $BicepFiles)
{
    bicep build $file
}     
```

</br>

## Bicep Templates

The templates shown in the video are provided below. You can also find downloadable versions here in the Github repo [HERE](/resources/day106/)

### resourceGroup.bicep

This bicep file drives an Azure resource group deployment.

```c#
/*

Template: resourceGroup.bicep

*/

// Standard Parameters.
param rgName string
param azLoc string

// Tag Parameters.
param rgTagName string
param rgTagEnvName string
param rgTagDeployedBy string

// Resource Group Template.
resource resourcGroup 'Microsoft.Resources/resourceGroups@2020-06-01' = {
  name: rgName
  location: azLoc
  tags:{
    Name: rgTagName
    Environment: rgTagEnvName
    DeployedBy: rgTagDeployedBy
  }
}
```

### storageAccount.bicep

This bicep file drives an Azure storage account deployment.

```c#
/*

Template: storageAccount.bicep

*/

// Standard Parameters.
param strName string
param strSku string
param strKind string
param strAccessTier string
param strSupportHttpsTrafficOnly bool
param strMinimumTlsVersion string
param azLoc string

// Tag Parameters.
param strTagName string
param strTagEnvName string
param strTagDeployedBy string

// Storage Account Template.
resource storageAccount 'Microsoft.Storage/storageAccounts@2019-06-01' = {
  name: strName
  location: azLoc
  kind: strKind
  sku: {
    name: strSku
  }
  properties: {
    accessTier: strAccessTier
    supportsHttpsTrafficOnly: strSupportHttpsTrafficOnly
    minimumTlsVersion: strMinimumTlsVersion
  }
  tags:{
    Name: strTagName
    Environment: strTagEnvName
    DeployedBy: strTagDeployedBy
  }
}
```

## Documentation Links

Azure Bicep documentation on Github
https://github.com/azure/bicep

Bicep resources from Build5nines.com.
https://build5nines.com/get-started-with-azure-bicep/

## Conclusion

We hope you enjoyed today's installment. If you have questions about this lesson or suggestions for future videos, leave us a comment here in the repo or reach out on LinkedIn for a chat!
