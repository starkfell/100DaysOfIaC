#!/bin/bash

#########################################################################################################
#
# Name:             Azure DB for PostgreSQL - AdventureWorks
#
# Description:      This script is responsible for deploying and configuring an Azure Database for PostgreSQL
#                   instance. Then, the script creates and populates the AdventureWorks database from 
#                   from the command line with the native psql utility.
# 
#########################################################################################################

# Parse Script Parameters.
while getopts ":i:t:r:u:p:d:x:c:n:s" opt; do
    case "${opt}" in
        i) # Azure Subscription ID.
             AZURE_SUBSCRIPTION_ID=${OPTARG}
             ;;
        t) # Azure Subscription Tenant ID.
             AZURE_SUBSCRIPTION_TENANT_ID=${OPTARG}
             ;;
        r) # The Resource Group name for the File Share & related resources.
             POSTGRES_RG=${OPTARG}
             ;;
        u) # Service Principal Username, used for deployment in Azure.
             MGMT_SP_USERNAME=${OPTARG}
             ;;
        p) # Service Principal Password, used for deployment in Azure.
             MGMT_SP_PASSWORD=${OPTARG}
             ;;
        d) # Postgres Admin Username that will be created for this instance
             DB_USERNAME=${OPTARG}
             ;;
        x) # Postgres Password. Note this must meet Microsoft's complexity requirements for this service.
             DB_PASSWORD=${OPTARG}
             ;;
        c) # The name for the Azure DB for PostgreSQL server instance.
             SVR_NAME=${OPTARG}
             ;;
        n) # Azure File Share Quota. 
             DB_NAME=${OPTARG}
             ;;
        s) # Azure File Share Quota. 
             SQL_FILE=${OPTARG}
             ;;
        \?) # Unrecognised option - show help.
            echo -e \\n"Option [-${BOLD}$OPTARG${NORM}] is not allowed. All Valid Options are listed below:"
            echo -e "-i AZURE_SUBSCRIPTION_ID                    - The Azure Subscription ID."
            echo -e "-t AZURE_SUBSCRIPTION_TENANT_ID             - The Azure Subscription Tenant ID."
            echo -e "-l AZURE_LOCATION                           - The Azure Location where instance will be deployed."
            echo -e "-r POSTGRES_RG                              - Resource group name for Azure DB for PostgreSQL instance."
            echo -e "-u MGMT_SP_USERNAME                         - Management Service Principal Username."
            echo -e "-p MGMT_SP_PASSWORD                         - Management Service Principal Password."
            echo -e "-d DB_USERNAME                              - Postgres Username." 
            echo -e "-x DB_PASSWORD                              - Postgres Password."
            echo -e "-c SVR_NAME                                 - The naming prefix for associated environment."                               
            echo -e "-b BACKUP_RET                               - Backup data retention (in days)."
            echo -e "-y GEO_BACKUP                               - Enable or disable geo backup of postgres data."
            echo -e "Script Syntax is shown below:"
            echo -e "./dbcreatepop.sh -i {AZURE_SUBSCRIPTION_ID} -t {AZURE_SUBSCRIPTION_TENANT_ID} -l {AZURE_LOCATION} -r {POSTGRES_RG} -u {MGMT_SP_USERNAME} -p {MGMT_SP_PASSWORD} -d {DB_USERNAME} -x {DB_PASSWORD} -c {SVR_NAME} -n {DB_NAME} -s {SQL_FILE} \\n"
            echo -e "An Example of how to use this script is shown below:"
            echo -e "./dbcreatepop.sh -i 0b62f50c-c15a-40e2-b1ab-7ac2596a1385 -t cf5b57b5-3bce-46f1-82b0-396341247726 -l eastus -r advwks-rg -u iac-sp -p '053c7e32-a074-4fea-a8fb-169883esdfwer' -d postgres -x 'PGP@ssw0rd!' -c advenwrks19 -n adventureworks -s install.sql \\n"
            exit 2
            ;;
    esac
done
shift $((OPTIND-1))

# Logging in to Azure as the Management Service Principal.
# /usr/bin/az login --service-principal -u "$K8S_MGMT_SP_USERNAME" -p $K8S_MGMT_SP_PASSWORD --tenant $AZURE_SUBSCRIPTION_TENANT_ID 
/usr/bin/az login --service-principal -u "http://$MGMT_SP_USERNAME" -p $MGMT_SP_PASSWORD --tenant $AZURE_SUBSCRIPTION_TENANT_ID # > /dev/null 2>&0

if [ $? -eq 0 ]; then
    echo "[$(date -u)][---success---] Logged into Azure as the Service Principal [$MGMT_SP_USERNAME]."
else
    echo "[$(date -u)][---fail---] Failed to login to Azure as the Service Principal [$MGMT_SP_USERNAME]."
    exit 2
fi

# Setting the Azure Subscription to work with.
/usr/bin/az account set -s $AZURE_SUBSCRIPTION_ID > /dev/null 2>&0

if [ $? -eq 0 ]; then
    echo "[$(date -u)][---success---] Azure CLI set to Azure Subscription [$AZURE_SUBSCRIPTION_ID]."
else
    echo "[$(date -u)][---fail---] Failed to set Azure CLI to Azure Subscription [$AZURE_SUBSCRIPTION_ID]."
    exit 2
fi

echo "Present working directory is " $PWD

#######################################
# PREREQ: Install Postgres client utils
#######################################

# This single line will install the utilities, including psql.
sudo apt-get -y install postgresql-client-10

     if [ $? -eq 0 ]; then
            echo "[$(date -u)][---info---] Postgres client tools installed successfully."
     else
            echo "[$(date -u)][---info---] Postgres client tools install failed."
            exit 2
     fi

##################################################
# Step 1: Verify the Azure DB for Postgres exists
##################################################

az postgres server show \
--resource-group "$POSTGRES_RG" \
--name "$SVR_NAME"  > /dev/null 2>&0

     if [ $? -eq 0 ]; then
            echo "[$(date -u)][---info---] Azure Postres instance [$SVR_NAME] already exists."
     else
            echo "[$(date -u)][---info---] Azure Postres instance [$SVR_NAME] not found."
            exit 2
     fi

#############################################
# Step 2 Create the Adventureworks database
#############################################

# create the database 
az postgres db create -s "$SVR_NAME" -g "$POSTGRES_RG" -n $DB_NAME

###################################################################
# Step 3 Populate the database(s) [assumes .sql file is present]
###################################################################

# populate the database (while avoiding the password prompt)
PGPASSWORD=$DB_PASSWORD psql -v sslmode=true -d $DB_NAME -h ${SVR_NAME}.postgres.database.azure.com -U ${DB_USERNAME}@${SVR_NAME} -a -f $SQL_FILE

