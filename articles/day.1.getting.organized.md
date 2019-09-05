# Day 1 - Getting Organized

One of the first things that often gets neglected when implementing Infrastructure as Code (IaC) is not having a way to reinstall all of your tools on your workstation in an automated fashion. At first this may not sound like something to even bother with; however, if the tools you are using are updated frequently or you are using a specific version of your tool due functionality issues, then having an automated way to redeploy all your tools becomes very important.

For this series, the following tools will be installed and configured on a fresh installation of **[Ubuntu 18.04.3 LTS](https://ubuntu.com/download/server/thank-you?country=AT&version=18.04.3&architecture=amd64)** with openSSH Server enabled.

Below are a list of tools that will be used throughout this series.

* Azure CLI
* PowerShell Core (Linux)
* Visual Studio Code
* Docker
* vim
* jq
* curl
* wget

*Note: We'll be covering and using several other tools throughout the series, this is just a start.*

<br />

## Azure CLI

Use the following command to install the latest version of Azure CLI available via **apt-get**

```bash
sudo apt-get update && \
sudo apt-get install -y ca-certificates curl apt-transport-https lsb-release gnupg && \
curl -sL https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor | sudo tee /etc/apt/trusted.gpg.d/microsoft.asc.gpg > /dev/null  && \
AZ_REPO=$(lsb_release -cs) && \
echo "deb [arch=amd64] https://packages.microsoft.com/repos/azure-cli/ $AZ_REPO main" | sudo tee /etc/apt/sources.list.d/azure-cli.list  && \
sudo apt-get update  && \
sudo apt-get install -y azure-cli
```

<br />

## PowerShell Core (Linux)

Use the following command to install the latest version of PowerShell Core available via **apt-get**

```bash
wget -q https://packages.microsoft.com/config/ubuntu/18.04/packages-microsoft-prod.deb && \
sudo dpkg -i packages-microsoft-prod.deb && \
sudo apt-get update && \
sudo add-apt-repository universe && \
sudo apt-get install -y powershell && \
sudo rm packages-microsoft-prod.deb

```

Run the following command to get into a PowerShell prompt.

```bash
pwsh
```

Run the following command to verify you are running the latest version of PowerShell Core.

```powershell
$PSVersionTable
```

Run the following command to get out of the PowerShell Core prompt and back to your **bash** prompt.

```powershell
exit
```

<br />

## vim, jq, curl, and wget

Run the following command to install **vim**, **jq**, **curl**, and **wget**.

```bash
sudo apt-get install -y vim jq curl wget
```

<br />

## Visual Studio Code

If you want to install Visual Studio Code manually and using a GUI, visit the [Visual Studio Code download page](https://code.visualstudio.com/Download).

To install Visual Studio Code from the command line, run the following command.

```bash
wget https://go.microsoft.com/fwlink/?LinkID=760868 -O vscode.deb && \
sudo apt install -y ./vscode.deb
```

## Docker

Run the following command to get install and configure docker.

```bash
sudo apt-get install -y docker.io && \
sudo usermod -a -G docker $USER
```

*Note: In order for the group permissions to take effect in the last line, you need to logout and log back into your Host.*

<br />

## All-in-one Install

If you need to reinstall in one shot in the future, run the command below. It's essentially a simple script with no error checking or idempotence, but it'll work if it's the first time you are setting up a new host.

```bash
sudo apt-get update && \
sudo apt-get install -y ca-certificates vim jq curl wget docker.io apt-transport-https lsb-release gnupg && \
curl -sL https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor | sudo tee /etc/apt/trusted.gpg.d/microsoft.asc.gpg > /dev/null  && \
AZ_REPO=$(lsb_release -cs) && \
echo "deb [arch=amd64] https://packages.microsoft.com/repos/azure-cli/ $AZ_REPO main" | sudo tee /etc/apt/sources.list.d/azure-cli.list  && \
sudo apt-get update  && \
sudo apt-get install -y azure-cli && \
wget -q https://packages.microsoft.com/config/ubuntu/18.04/packages-microsoft-prod.deb && \
sudo dpkg -i packages-microsoft-prod.deb && \
sudo apt-get update && \
sudo add-apt-repository universe && \
sudo apt-get install -y powershell && \
sudo rm packages-microsoft-prod.deb && \
sudo usermod -a -G docker $USER && \
wget https://go.microsoft.com/fwlink/?LinkID=760868 -O vscode.deb && \
sudo apt install -y ./vscode.deb
```
