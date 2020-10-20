# Day 102 - Azure SQL Deployment and Security (Part 1)

In the first of a 2-part video session, we begin a look at deployment options and security features of Azure SQL. Resources from this session are detailed below, along with the link to the video on YouTube.

In this article:

- Related installments
- YouTube video
- Video resources
- Azure Cloud Shell transcript (from live session)

## Related installments

You will find some of the code samples shown in this session in the articles below:

[Day 86 - Deploying Azure SQL Server using the Azure CLI](https://github.com/starkfell/100DaysOfIaC/blob/master/articles/day.86.deploying.azure.sql.srv.azure.cli.md) </br>
[Day 87 - Deploying Azure SQL Server using ARM](https://github.com/starkfell/100DaysOfIaC/blob/master/articles/day.87.deploying.azure.sql.srv.arm.md)</br>

[ARTICLE: 5 ways to secure your SQL data in Microsoft Azure](https://www.linkedin.com/pulse/5-ways-secure-your-sql-data-microsoft-azure-pete-zerger/) </br>

***
SPONSOR: Need to stop and start your development VMs on a schedule? The Azure Resource Scheduler let's you schedule up to 10 Azure VMs for FREE! Learn more [HERE](https://azuremarketplace.microsoft.com/en-us/marketplace/apps/lumagatena.resourcescheduler?tab=Overview)
***

## YouTube Video

Watch the video on YouTube at [https://youtu.be/hzXs3zvGR7M](https://youtu.be/hzXs3zvGR7M)

**TO SUBSCRIBE:** Click **[HERE](https://www.youtube.com/channel/UCAr0yk0um7lwLjmrKfzwyig?sub_confirmation=1)** to follow us on Youtube so you get a heads up on future videos!

A few areas we covered in this video include:

Deployment Automation
- ARM
- Azure CLI
- Azure PowerShell

Security
How and tell around the following security features:

- Authentication options (SQL, Azure AD)
- Resource firewall
- TDE
- Audit log configuration

**TUTORIAL: Use PowerShell to create a single database and configure a server-level firewall rule**
https://docs.microsoft.com/en-us/azure/azure-sql/database/scripts/create-and-configure-database-powershell?toc=/powershell/module/toc.json

**Auditing for Azure SQL Database**
https://docs.microsoft.com/en-us/azure/azure-sql/database/auditing-overview

**Collection of Azure PowerShell samples for Azure SQL**
Here’s the full list of PowerShell samples we can point them to:
https://docs.microsoft.com/en-us/azure/azure-sql/database/powershell-script-content-guide?tabs=single-database

**Tutorial: Secure a database in Azure SQL Database**

https://docs.microsoft.com/en-us/azure/azure-sql/database/secure-database-tutorial

# Transcript (live Cloud Shell during session)

```bash
## Transcript

    1  exit
    2  clear
    3  ls -lh
    4  clear
    5  ls -lh
    6  az group list --query [].name
    7  clear
    8  az group create --name 100days-azuredb --location eastus
    9  clear
   10  az group create --name 100days-azuredb --location eastus --output jsonc
   11  clear
   12  cat /proc/sys/kernel/random/uuid
   13  SQL_SRV_ADMIN_PASSWORD=$(cat /proc/sys/kernel/random/uuid)
   14  echo $SQL_SRV_ADMIN_PASSWORD
   15  RANDOM_ALPHA=$(cat /dev/urandom | tr -dc 'a-z0-9' | fold -w 4 | head -n 1)
   16  cat /dev/urandom
   17  clear
   18  RANDOM_ALPHA=$(cat /proc/sys/kernel/random/uuid | tr -dc 'a-z0-9' | fold -w 4 | head -n 1)
   19  echo $RANDOM
   20  echo $RANDOM_ALPHA
   21  az sql server create --name "100days-azuresqlsrv-$RANDOM_ALPHA" --resource-group "100days-azuredb" --location "eastus"--admin-user "sqladmdays" --admin-password $SQL_SRV_ADMIN_PASSWORD --query '[name,state]' --output tsv
   22  az sql server list --query [].name
   23  clear
   24  az sql db create --name "wide-world-imports-std" --resource-group "100days-azuredb" --server "100days-azuresqlsrv-$RANDOM_ALPHA" --edition Standard --family Gen5 --service-objective S2 --query '[name,status]' --output tsv
   25  az sql server firewall-rule create --name "allow-azure-services" --resource-group "100days-azuredb" --server "100days-azuresqlsrv-$RANDOM_ALPHA" --start-ip-address "0.0.0.0" --end-ip-address "0.0.0.0"
   26  az sql server firewall-rule create --name "allow-pete-zerger-home-access" --resource-group "100days-azuredb" --server "100days-azuresqlsrv-$RANDOM_ALPHA" --start-ip-address 73.166.232.69" \
   27  --end-ip-address "73.166.232.69"
   28  clear
   29  az sql server firewall-rule create --name "allow-pete-zerger-home-access" --resource-group "100days-azuredb" --server "100days-azuresqlsrv-$RANDOM_ALPHA" --start-ip-address "73.166.232.69" --end-ip-address "73.166.232.69"
   30  clear
   31  history
   ```

## Conclusion

This has been part 1 of a 2-part dive into Azure SQL. If you've never tried it, try the Azure PowerShell tutorial revisit Days 86 and 87 and try the Azure CLI and ARM samples to get some hands-on experience.