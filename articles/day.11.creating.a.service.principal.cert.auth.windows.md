# Day 11 - Creating an Azure Service Principal that uses Certificate Authentication (Windows Edition)

In our previous article **[Day 9](https://github.com/starkfell/100DaysOfIaC/blob/master/articles/day.9.creating.a.service.principal.cert.auth.linux.md)** we created a Service Principal with Certificate Authentication in Linux. Today we are covering how to create a Service Principal that uses a PEM Certificate for authentication using the Azure CLI on Windows.

> **NOTE:** This article was tested and written for a Windows Host running Windows 10.

<br />

In this installment, we'll be going over the following.

[Installing OpenSSL using Chocolatey](#install-openssl-using-chocolatey)<br />
[Generate a new PEM Certificate](#generate-a-new-pem-certificate)<br />
[Create the Service Principal](#create-the-service-principal)<br />
[Test the Service Principal](#test-the-service-principal)<br />
[Updating a Service Principal Certificate](#updating-a-service-principal-certificate)<br />
[Conclusion](#conclusion)<br />

***
SPONSOR: Need to stop and start your development VMs on a schedule? The Azure Resource Scheduler let's you schedule up to 10 Azure VMs for FREE! Learn more [HERE](https://azuremarketplace.microsoft.com/en-us/marketplace/apps/lumagatena.resourcescheduler?tab=Overview)
***

## Install OpenSSL using Chocolatey

Open up an Elevated PowerShell prompt and run the following command to install **openssl** using Chocolatey

```powershell
choco install openssl -y
```

> **NOTE:** As of the writing of this article, the following message will appear when installing **openssl**.<br />
>
> *WARNING: OPENSSL_CONF has been set to C:\Program Files\OpenSSL-Win64\openssl.cfg*<br />
>
> the **openssl.cfg** file by default is in *C:\Program Files\OpenSSL-Win64\openssl.cfg* which is why the path in the **OPENSSL_CONF** variable is updated in the section below.

<br />

Run the following command to update the **Path** System Variable to include the path to the **openssl** executable.

```powershell
$CurrentPath = (Get-ItemProperty `
-Path 'Registry::HKEY_LOCAL_MACHINE\System\CurrentControlSet\Control\Session Manager\Environment' -Name PATH).path ; `
$NewPath = "$CurrentPath;C:\Program Files\OpenSSL-Win64\bin" ; `
Set-ItemProperty `
-Path 'Registry::HKEY_LOCAL_MACHINE\System\CurrentControlSet\Control\Session Manager\Environment' `
-Name PATH `
-Value $NewPath
```

Run the following command to update the **OPENSSL_CONF** System Variable to point to the **openssl.cfg** file.

```powershell
Set-ItemProperty `
-Path 'Registry::HKEY_LOCAL_MACHINE\System\CurrentControlSet\Control\Session Manager\Environment' `
-Name OPENSSL_CONF `
-Value "C:\Program Files\OpenSSL-Win64\bin\openssl.cfg"
```

Next, close out of the elevated PowerShell Prompt before continuing.

<br />

## Generate a new PEM Certificate

Open up an Elevated PowerShell prompt and **cd** into your home directory.

```powershell
cd ~
```

Next run the following command to generate a self-signed PEM Certificate.

```powershell
openssl req `
-utf8 `
-x509 `
-newkey rsa:2048 `
-sha256 `
-days 365 `
-nodes `
-subj "/C=AT/ST=Styria/L=Graz/O=100 Days of IaC/OU=Bloggers/CN=starkfell.github.io" `
-keyout key.pem `
-out cert.pem ; `
cat key.pem > iac-sp-cert.pem ; `
cat cert.pem >> iac-sp-cert.pem ; `
$PEM_Cert = Get-Content .\iac-sp-cert.pem ; `
$PEM_Cert | Out-File -Encoding ASCII .\iac-sp-cert.pem
```

> **NOTE:** The two lines of code above that convert the **iac-sp-cert.pem** file to ASCII are necessary to ensure the certificate is saved in UTF-8 Format. Otherwise the file is saved in UTF16-LE and when you attempt to login as the service principal, you'll get the following encoding error message: *'ascii' codec can't encode characters in position 0-1: ordinal not in range(128)*.

<br />

You should get back the following output when the certificate is finished being generated.

```console
Generating a RSA private key
..........+++++
...............................+++++
writing new private key to 'key.pem'
-----
```

If you run **dir** in your PowerShell Prompt you should see the following files.

```console
-rw-rw-r-- 1 USERNAME USERNAME 1.4K Sep 12 09:29 cert.pem
-rw-rw-r-- 1 USERNAME USERNAME 3.1K Sep 12 09:29 iac-sp-cert.pem
-rw------- 1 USERNAME USERNAME 1.7K Sep 12 09:29 key.pem
```

> **NOTE:** The **cert.pem** and **key.pem** files are no longer needed as they are combined together in the **iac-sp-cert.pem** file.

<br />

## Create the Service Principal

Run the following command to generate a new Service Principal using the PEM Certificate.

```powershell
az ad sp create-for-rbac `
--role "contributor" `
--name "iac-sp" `
--cert @iac-sp-cert.pem
```

You should get back something similar to what is shown below.

```console
Changing "iac-sp" to a valid URI of "http://iac-sp", which is the required format used for service principal
names Certificate expires 2020-09-12 09:43:25+00:00. Adjusting SP end date to match.
Creating a role assignment under the scope of "/subscriptions/00000000-0000-0000-0000-000000000000"
  Retrying role assignment creation: 1/36
  Retrying role assignment creation: 2/36
  Retrying role assignment creation: 3/36
{
  "appId": "00000000-0000-0000-0000-000000000000",
  "displayName": "iac-sp",
  "name": "http://iac-sp",
  "password": null,
  "tenant": "00000000-0000-0000-0000-000000000000"
}
```

> Note: If you attempt to add certificate authentication to an existing Service Principal with password authentication, it will only add the certificate or overwrite the existing certificate associated with the Service Principal. Any existing Password authentication will still be valid.

<br />

## Test the Service Principal

Run the command below and replace the **--tenant** value with either the **FQDN** or the **GUID** of your Azure Active Directory Tenant ID.

```powershell
az login `
--service-principal `
-u http://iac-sp `
-p iac-sp-cert.pem `
--tenant 00000000-0000-0000-0000-000000000000
```

You should get back the following response verifying that you are logged in to the Azure Subscriptions as the Service Principal.

```console
[
  {
    "cloudName": "AzureCloud",
    "id": "00000000-0000-0000-0000-000000000000",
    "isDefault": true,
    "name": "{AZURE_SUBSCRIPTION_NAME}",
    "state": "Enabled",
    "tenantId": "00000000-0000-0000-0000-000000000000",
    "user": {
      "name": "http://iac-sp",
      "type": "servicePrincipal"
    }
  }
]
```

> **NOTE:** Don't forget to logout and log back in to Azure with your normal credentials after testing the Service Principal; otherwise, you will be stay logged in as the Service Principal and you may find that the rights of the Service Principal are limited compared to your own.

<br />

## Updating a Service Principal Certificate

Updating the Certificate for the Service Principal is as easy as creating a new PEM certificate and then running the command to create a new Service Principal using the commands demonstrated earlier. When the command to create a new Service Principal is ran, you'll notice the idempotence of Azure CLI as the Service Principal will be updated instead of attempting to create a new one.

```console
Changing "iac-sp" to a valid URI of "http://iac-sp", which is the required format used for service principal
names Certificate expires 2020-09-12 09:50:29+00:00. Adjusting SP end date to match.
Found an existing application instance of "00000000-0000-0000-0000-000000000000". We will patch it
Creating a role assignment under the scope of "/00000000-0000-0000-0000-000000000000"
  Role assignment already exits.

{
  "appId": "00000000-0000-0000-0000-000000000000",
  "displayName": "iac-sp",
  "name": "http://iac-sp",
  "password": null,
  "tenant": "00000000-0000-0000-0000-000000000000"
}
```

<br />

## Conclusion

If you plan on deploying IaC to the Azure Cloud using IaC Tools such as ARM, Ansible, or Terraform, you may want to consider using Certificate Based Authentication for your Service Principals as an alternative to standard Password Authentication. The steps above can be easily compiled together into a script whereby you would be able to generate new Certificates for your Service Principals on the fly for scenarios such as:

* Deploying a new Service Principals
* Resetting an expired Service Principal Certificate
* Resetting a compromised Service Principal Certificate
