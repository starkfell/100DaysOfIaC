
# Day 103 - Azure SQL Deployment and Security (Part 2)

In the first of a 2-part video session, we begin a look at deployment options and security features of Azure SQL. Resources from this session are detailed below, along with the link to the video on YouTube. You'll find code samples and tutorials throughout the "related installments" and "Video resources", so be sure to get some hands-on practice!

In this article:

- Related installments
- YouTube Video
- Related Articles

## Related Installments

You will find some of the code samples shown in this session in the articles below:

[Day 88 - SQL BACPAC Files and Azure CLI](https://github.com/starkfell/100DaysOfIaC/blob/master/articles/day88.sql.bacpac.md)</br>
[Day 87 - Deploying Azure SQL Server using ARM](https://github.com/starkfell/100DaysOfIaC/blob/master/articles/day.87.deploying.azure.sql.srv.arm.md)</br>
[Day 86 - Deploying Azure SQL Server using the Azure CLI](https://github.com/starkfell/100DaysOfIaC/blob/master/articles/day.86.deploying.azure.sql.srv.azure.cli.md) </br>

***
SPONSOR: Need to stop and start your development VMs on a schedule? The Azure Resource Scheduler let's you schedule up to 10 Azure VMs for FREE! Learn more [HERE](https://azuremarketplace.microsoft.com/en-us/marketplace/apps/lumagatena.resourcescheduler?tab=Overview)
***

## YouTube Video

Watch the video on YouTube at [https://youtu.be/ZF5CtcEovJc](https://youtu.be/ZF5CtcEovJc)

**TO SUBSCRIBE:** Click **[HERE](https://www.youtube.com/channel/UCAr0yk0um7lwLjmrKfzwyig?sub_confirmation=1)** to follow us on Youtube so you get a heads up on future videos!

A few areas we covered in this video include:

Deployment Automation

- Importing a SQL database (BACPAC) via CLI
- How to import BACPAC via Azure Portal 

Security

How the resource firewall works on Azure SQL

## Related Articles

Import a BACPAC File to Create a New User Database
https://docs.microsoft.com/en-us/sql/relational-databases/data-tier-applications/import-a-bacpac-file-to-create-a-new-user-database?view=sql-server-ver15

Export to a BACPAC file - Azure SQL Database and Azure SQL Managed Instance
https://docs.microsoft.com/en-us/azure/azure-sql/database/database-export

BACPAC and DACPAC
https://docs.microsoft.com/en-us/sql/relational-databases/data-tier-applications/data-tier-applications?view=sql-server-ver15#:~:text=be%20implicitly%20registered.-,BACPAC,a%20database's%20schema%20and%20data.&text=A%20DACPAC%20is%20focused%20on,including%20upgrading%20an%20existing%20database.

Azure SQL Database and Azure Synapse IP firewall rules
https://docs.microsoft.com/en-us/azure/azure-sql/database/firewall-configure
https://docs.microsoft.com/en-us/azure/azure-sql/database/media/firewall-configure/sqldb-firewall-1.png

Azure SQL database deployment(Azure DevOps pipeline)
https://docs.microsoft.com/en-us/azure/devops/pipelines/targets/azure-sqldb?view=azure-devops&tabs=yaml

Azure SQL Database Deployment task
https://docs.microsoft.com/en-us/azure/devops/pipelines/tasks/deploy/sql-azure-dacpac-deployment?view=azure-devops

AAD Pod Identity
https://github.com/Azure/aad-pod-identity

Best practices for pod security in Azure Kubernetes Service (AKS)
https://docs.microsoft.com/en-us/azure/aks/developer-best-practices-pod-security#use-pod-managed-identities

Azure Kubernetes Service, Azure SQL DB and Managed Identity
https://docs.microsoft.com/en-us/azure/aks/developer-best-practices-pod-security#use-pod-managed-identities

https://docs.microsoft.com/en-us/azure/aks/media/developer-best-practices-pod-security/basic-pod-identity.svg

## Conclusion

This has been part 2 of a 2-part dive into Azure SQL. If you've never tried it, try importing a SQL database (BACPAC) as demonstrated in this video and with code provided in DAYS 86 and 87 to get some hands-on experience.
