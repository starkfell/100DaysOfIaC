# Day 88 - SQL BACPAC Files and Azure CLI

In yesterday's installment, we stepped through the details of Azure SQL from ARM. In that article, we imported a database into the new instance from a BACPAC file. What is a BACPAC file? We're going to dig a little further into the BACPAC, a very useful feature that's been around a very long time.

In this article:

[What is a BACPAC file?](#what-is-a-bacpac-file) </br>
[Operations, Tools, and Methods](#operations-tools-and-methods) </br>
[Permissions](#permissions) </br>
[Export your SQL database to a BACPAC file](#export-your-sql-database-to-a-bacpac-file) </br>
[Import a new SQL database from a BACPAC file](#import-a-new-sql-database-from-a-bacpac-file) </br>

## What is a BACPAC file?

A [BACPAC](https://docs.microsoft.com/en-us/sql/relational-databases/data-tier-applications/data-tier-applications?redirectedfrom=MSDN&view=sql-server-ver15#bacpac) is a file with a .bacpac extension that contains a database schema and data. The primary use cases for a BACPAC include:

- Moving a database between servers
- Migrating a local database to the cloud
- Archiving an existing database to an open format

In short, the BACPAC is super-handy in cloud migration scenarios, whether moving to SQL on Azure VMs (IaaS) or Azure SQL (PaaS).

> **NOTE**: BACPACs are not intended to be used for backup and restore operations. As mentioned earlier in this series, Azure Database automatically creates backups for every user database.

## Operations, Tools, and Methods

When working with a BACPAC file, you'll likely be performing one of two operations: IMPORT or an EXPORT. Both these capabilities are supported by the database management tools: SQL Server Management Studio, the Azure Portal, [DACFx API](https://blogs.msmvps.com/deborahk/deploying-a-dacpac-with-dacfx-api/), as well as ARM and the Azure CLI.

We'll be focused on import and export of BACPAC of your Azure SQL database with the [Azure portal](https://portal.azure.com).

# Permissions

Before you attempt export or import, make sure you have the right permissions. You must be a member of the **dbmanager** role or assigned **CREATE DATABASE** permissions to create a database, including creating a database by deploying a DAC package. You must be a member of the **dbmanager** role, or have been assigned **DROP DATABASE** permissions to drop a database.

## Export your SQL database to a BACPAC file

You import a BACPAC into an existing database with the Azure CLI using the `az sql db export` command.

First, get a SAS key for use in the export operation.

``` bash
az storage blob generate-sas \
--account-name myAccountName \
-c myContainer -n myBacpac.bacpac \
--permissions w --expiry 2020-31-01T00:00:00Z
```

Then, Export to BACPAC using an SAS key.

``` bash
az sql db export -s myserver -n contoso -g mygroup -p password -u login \
    --storage-key "?sr=b&sp=rw&se=2020-01-31T00%3A00%3A00Z&sig=mysignature&sv=2019-01-01" \
    --storage-key-type SharedAccessKey \
    --storage-uri https://contosoAcctName.blob.core.windows.net/bacpacContainer/contoso.bacpac
```

To guarantee a transaction-consistent BACPAC file, you may first want to create a copy of your database and then export from the copy.

## Import a new SQL database from a BACPAC file

The BACPAC import process in Azure is supported natively in Azure with ARM, but also with Azure CLI.The BACPAC import process in the Azure context is essentially two steps

- The BACPAC is exported into an Azure storage blob container
- The BACPAC is then downloaded and imported on the target server

You import a BACPAC into an existing database with the Azure CLI using the `az sql db import` command.

For a detailed step-by-step example, simply visit ["Import the Database into the Azure SQL Server"](https://github.com/starkfell/100DaysOfIaC/blob/master/articles/day.87.deploying.azure.sql.srv.arm.md#import-the-database-into-the-azure-sql-server) in Day 87!

If you do not have an Azure SQL server or database, or the storage account to upload the BACPAC to, start at the beginning of yesterday's installment of this series: [Day 87 - Deploying Azure SQL Server using ARM](day.87.deploying.azure.sql.srv.arm.md).


## Conclusion

This is a quick look at the BACPAC. If you've never tried it, revisit Day 87 and try the Azure CLI and ARM samples to get some hands-on experience.
