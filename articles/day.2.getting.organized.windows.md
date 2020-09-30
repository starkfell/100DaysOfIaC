# Day 2 - Getting Organized (Windows)

In the previous article **[Day 1 - Getting Organized (Linux)](https://github.com/starkfell/100DaysOfIaC/blob/master/articles/day.1.getting.organized.md)** we covered how to install all of your tools on a workstation in an automated way so that if you ever had to rebuild the workstation, you could either run a simple all-in-one script or copy/paste a few lines of code and be up and running. Today we'll be doing the same for a workstation running Windows 10.

Below are a list of tools that will be used throughout this series on Windows.

* Chocolatey
* Azure CLI
* PowerShell Core
* Visual Studio Code
* Docker

*Note: We'll be covering and using several other tools throughout the series, this is just a start.*

<br />

***
SPONSOR: Need to stop and start your development VMs on a schedule? The Azure Resource Scheduler let's you schedule up to 10 Azure VMs for FREE! Learn more [HERE](https://azuremarketplace.microsoft.com/en-us/marketplace/apps/lumagatena.resourcescheduler?tab=Overview)
***

## Chocolatey

In the setup of the Linux Host (Ubuntu 18.04) we used a combination of source installations and package management. For Windows 10, we are going to use Chocolatey for installing our starting packages.

Open up a Powershell Prompt as Administrator and run the following command to install Chocolatey.

*Note: It's recommended to verify the contents of the **[install.ps1](https://chocolatey.org/install.ps1)** script from Chocolatey before running this command.*

```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
```

<br />

## Azure CLI

Run the following command to install the Azure CLI using Chocolatey.

```powershell
choco install azure-cli -y
```

<br />

## PowerShell Core

Run the following command to to install PowerShell Core using Chocolatey.

```powershell
choco install powershell-core -y
```

<br />

## Visual Studio Code

Run the following command to to install Visual Studio Code using Chocolatey.

```powershell
choco install vscode -y
```

<br />

## Docker

Run the following command to to install Docker using Chocolatey.

```powershell
choco install docker-desktop -y
```

<br />

## All-in-one Install

If you need to reinstall everything in one shot in the future, run the command below. It's essentially a simple script with no error checking or idempotence, but it'll work if it's the first time you are setting up a new workstation.

```powershell
Set-ExecutionPolicy Bypass `
-Scope Process `
-Force; `
iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1')) ; `
choco install azure-cli powershell-core vscode docker-desktop googlechrome openssl git -y
```

At the bottom of the PowerShell Prompt after running the command above, you should see the following output.

```powershell
Chocolatey installed 10/10 packages.
 See the log for details (C:\ProgramData\chocolatey\logs\chocolatey.log).

Installed:
 - kb2919355 v1.0.20160915
 - chocolatey-core.extension v1.3.3
 - kb2999226 v1.0.20181019
 - azure-cli v2.0.72
 - docker-desktop v2.1.0.2
 - kb2919442 v1.0.20160915
 - vscode v1.38.0
 - powershell-core v6.2.2
 - dotnet4.5.2 v4.5.2.20140902
 - chocolatey-windowsupdate.extension v1.0.4
```
