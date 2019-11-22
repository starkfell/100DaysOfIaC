## Day 57 -  The Ultimate Pipeline-friendly Azure DB for PostgreSQL Script

With Azure DB for PostgreSQL, you can deploy the Postgres version of your choice, with the compute . We've talked repeatedly about the flexibility of using Azure CLI (bash) in your day-to-day, non-prod releases. Today, we offer a script, designed to run in a release pipeline in Azure Pipelines, and by request, we've left in Azure KeyVault integration for storing secrets related to the Postgres instance.

This performs the following configuration of your Azure PostgreSQL instance, including:

- Logs in as a service principal
- Switches context to the Azure sub
- Checks for the prerequisites needed on the build agent
- Deploys the Azure DB for PostgreSQL instance for version you specify
- Sets the SKU 
- Enables geo-redundant backup storage, if desired
- Sets whitelisted IP addresses for remote access
- Stores the connection endpoint in Azure KeyVault
- Retrieves and stores the Postgres user and password in Azure KeyVault

## SAMPLE SCRIPT

The script, and command line syntax are shown here, well-commented so you know what's happening at every stage. The full script is shown below, as well as in the [day57](../resources/day57) folder in the resources in this Git repository.

**SYNTAX:**

``` Bash
./createpostgres.sh -i 5345deaa-0037-4785-8ce9-7c6a3c43k48t -t e7453b1c-6356-4cc1-a495-d74eccd3kf83 -l eastus -r MyResGrp -u svcprncpl -p 'MyPassword' -d postgres -x 'MyPassword' -c cust1 -v 9.6 -k GP_Gen5_2 -b 7 -y Disabled
```

``` Bash
#!/bin/bash

#########################################################################################################
#
# Name:             Create Azure DB for PostgreSQL instance and databases
#
# Author:           Pete Zerger  
# 
# Description:      This script is responsible for deploying an Azure DB for Postgres instance.
#
# Sample:           see parameter documentation and example at the head of the script below.
#
#########################################################################################################

# Parse Script Parameters.
while getopts ":i:t:l:r:u:p:d:x:c:v:k:b:y:" opt; do
    case "${opt}" in
        i) # Azure Subscription ID.
             AZURE_SUBSCRIPTION_ID=${OPTARG}
             ;;
        t) # Azure Subscription Tenant ID.
             AZURE_SUBSCRIPTION_TENANT_ID=${OPTARG}
             ;;
        l) # Azure Location.
             AZURE_LOCATION=${OPTARG}
             ;;
        r) # The Resource Group name for the File Share & related resources.
             POSTGRES_RG=${OPTARG}
             ;;
        u) # Management Service Principal Username. This is used for managing all Postgres DBs in an Azure Subscription.
             MGMT_SP_USERNAME=${OPTARG}
             ;;
        p) # Management Service Principal Password.
             MGMT_SP_PASSWORD=${OPTARG}
             ;;
        d) # Postgres Username. This is used for managing all Postgres DBs in an Azure Subscription.
             DB_USERNAME=${OPTARG}
             ;;
        x) # Postgres Password.
             DB_PASSWORD=${OPTARG}
             ;;
        c) # The naming prefix for associated environment.
             ENVIRONMENT=${OPTARG}
             ;;
        v) # Major and minor PostgreSQL version number.
             POSTGRES_VERSION=${OPTARG}
             ;;
        k) # Azure DB for Postgres SKU.
             SKU_NAME=${OPTARG}
             ;;
        b) # Set backup retention (days)
             BACKUP_RET=${OPTARG}
             ;;
        y) # Enable geo-backup 
             GEO_BACKUP=${OPTARG}
             ;;
        \?) # Unrecognised option - show help.
            echo -e \\n"Option [-${BOLD}$OPTARG${NORM}] is not allowed. All Valid Options are listed below:"
            echo -e "-i AZURE_SUBSCRIPTION_ID                    - The Azure Subscription ID."
            echo -e "-t AZURE_SUBSCRIPTION_TENANT_ID             - The Azure Subscription Tenant ID."
            echo -e "-l AZURE_LOCATION                           - The Azure Location where the File Share will be deployed."
            echo -e "-r POSTGRES_RG                              - Azure File Share name for PostgreSQL."
            echo -e "-u MGMT_SP_USERNAME                         - Management Service Principal Username. This is used for managing all Postgres DBs in an Azure Subscription."
            echo -e "-p MGMT_SP_PASSWORD                         - Management Service Principal Password."
            echo -e "-d DB_USERNAME                              - Postgres Username." 
            echo -e "-x DB_PASSWORD                              - Postgres Password."
            echo -e "-c ENVIRONMENT                              - The naming prefix for associated environment."
            echo -e "-v POSTGRES_VERSION                         - Postgres version nubmer to deploy."
            echo -e "-k SKU_NAME                                 - Azure DB for Postgres SKU."
            echo -e "-b BACKUP_RET                               - Backup data retention (in days)."
            echo -e "-y GEO_BACKUP                               - Enable or disable geo backup of postgres data."
            echo -e "Script Syntax is shown below:"
            echo -e "./createpostgres.sh -i {AZURE_SUBSCRIPTION_ID} -t {AZURE_SUBSCRIPTION_TENANT_ID} -l {AZURE_LOCATION} -r {POSTGRES_RG} -u {MGMT_SP_USERNAME} -p {MGMT_SP_PASSWORD} -d {DB_USERNAME} -x {DB_PASSWORD} -c {ENVIRONMENT} -v {POSTGRES_VERSION} -k {SKU_NAME} -b {BACKUP_RET} -y {GEO_BACKUP}"
            echo -e "An Example of how to use this script is shown below:"
            echo -e "./createpostgres.sh -i 5345deaa-0037-4785-8ce9-7c6a3c43k48t -t e7453b1c-6356-4cc1-a495-d74eccd3kf83 -l eastus -r MyResGrp -u svcprncpl -p 'MyPassword' -d postgres -x 'MyPassword' -c cust1 -v 9.6 -k GP_Gen5_2 -b 7 -y Disabled \\n"
            exit 2
            ;;
    esac
done
shift $((OPTIND-1))

# Verifying the Script Parameters Values exist.
if [ -z "${AZURE_SUBSCRIPTION_ID}" ]; then
    echo "[$(date -u)][---fail---] The Azure Subscription ID must be provided."
    exit 2
fi

if [ -z "${AZURE_SUBSCRIPTION_TENANT_ID}" ]; then
    echo "[$(date -u)][---fail---] The Azure Subscription Tenant ID must be provided."
    exit 2
fi

if [ -z "${AZURE_LOCATION}" ]; then
    echo "[$(date -u)][---fail---] Management Service Principal Username must be provided."
    exit 2
fi

if [ -z "${POSTGRES_RG}" ]; then
    echo "[$(date -u)][---fail---] Resource group name for Postgres instance must be provided."
    exit 2
fi

if [ -z "${MGMT_SP_USERNAME}" ]; then
    echo "[$(date -u)][---fail---] Management Service Principal Username must be provided."
    exit 2
fi

if [ -z "${MGMT_SP_PASSWORD}" ]; then
    echo "[$(date -u)][---fail---] Management Service Principal Password must be provided."
    exit 2

if [ -z "${DB_USERNAME}" ]; then
    echo "[$(date -u)][---fail---] The Postgres Azure Storage Account Name being created must be provided."
    exit 2
fi

if [ -z "${DB_PASSWORD}" ]; then
    echo "[$(date -u)][---fail---] The Postgres Azure Storage Account Name being created must be provided."
    exit 2
fi

if [ -z "${ENVIRONMENT}" ]; then
    echo "[$(date -u)][---fail---] The K8s naming prefix must be included."
    exit 2
fi

if [ -z "${POSTGRES_VERSION}" ]; then
    echo "[$(date -u)][---fail---] The PostgreSQL Azure Resource Group must be included."
    exit 2
fi

if [ -z "${SKU_NAME}" ]; then
    echo "[$(date -u)][---fail---] The PostgreSQL Azure Resource Group must be included."
    exit 2
fi

if [ -z "${BACKUP_RET}" ]; then
    echo "[$(date -u)][---fail---] The PostgreSQL Azure Resource Group must be included."
    exit 2
fi

if [ -z "${GEO_BACKUP}" ]; then
    echo "[$(date -u)][---fail---] The Azure Location where to deploy the Cluster must be provided."
    exit 2
fi


# Logging in to Azure as the Management Service Principal.

/usr/bin/az login --service-principal -u "http://$MGMT_SP_USERNAME" -p $MGMT_SP_PASSWORD --tenant $AZURE_SUBSCRIPTION_TENANT_ID > /dev/null 2>&0

if [ $? -eq 0 ]; then
    echo "[$(date -u)][---success---] Logged into Azure as the Management Service Principal [$MGMT_SP_USERNAME]."
else
    echo "[$(date -u)][---fail---] Failed to login to Azure as the Management Service Principal [$MGMT_SP_USERNAME]."
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

###################################
# Step 1: Create the Resource Group
###################################

/usr/bin/az group show \
--resource-group $POSTGRES_RG \
--subscription $AZURE_SUBSCRIPTION_ID > /dev/null 2>&0

        if [ $? -eq 0 ]; then
            echo "[$(date -u)][---info---] Resource Group [$POSTGRES_RG] already exists."
        else
            echo "[$(date -u)][---info---] Resource Group [$POSTGRES_RG] not found."

        # Create a resource group
        # az group create --name $POSTGRES_FILE_RG --location $AZURE_LOCATION > /dev/null 2>&0

        az group create \
        --name $POSTGRES_RG \
        --location $AZURE_LOCATION > /dev/null 2>&0

        if [ $? -eq 0 ]; then
        echo "[$(date -u)][---success---] Created the Resource Group [$POSTGRES_RG] for the Postgres instance."
    else
        echo "[$(date -u)][---fail---] Failed to create the Resource Group [$POSTGRES_RG] for the Postgres instance."
        exit 2
    fi
fi


###################################
# Step 2: Deploy the Postgres Server
###################################

az postgres server create \
--location $AZURE_LOCATION \
--name "$ENVIRONMENT" \
--version "$MAJOR_VERSION" \
--sku-name "$SKU_NAME" \
--admin-user "$DB_USERNAME" \
--admin-password "$DB_PASSWORD" \
--resource-group "$POSTGRES_RG" \
--backup-retention "$BACKUP_RET" \
--geo-redundant-backup "$GEO_BACKUP" \
--storage-size 51200 
# > /dev/null 2>&0


########################################################
# Step 3: Configure a firewall rule for the server
########################################################

# The ip address range that you want to allow to access your server
az postgres server firewall-rule create \
--resource-group "$POSTGRES_RG" \
--server "$ENVIRONMENT" \
--name AllowIps \
--start-ip-address 0.0.0.0 \
--end-ip-address 255.255.255.255  > /dev/null 2>&0

########################################################
# Step 4: Add database connection info to Azure Key Vault
########################################################

        # Server FQDN
        KEYVAULTNAME="$ENVIRONMENT-keyvault"
        POSTGRES_FQDN="$ENVIRONMENT.postgres.database.azure.com"
        
        # Postgres User 
        POSTGRES_USER="$DB_USERNAME"

        # Postgres Password 
        POSTGRES_PASSWORD="$DB_PASSWORD"

        # Adding the Postgres Server FQDN to Azure Key Vault.
        /usr/bin/az keyvault secret set \
        --name "${ENVIRONMENT}-postgres-fqdn" \
        --vault-name "$KEYVAULTNAME" \
        --subscription "$AZURE_SUBSCRIPTION_ID" \
        --value "$POSTGRES_FQDN" > /dev/null 2>&0

        if [ $? -eq 0 ]; then
            echo "[$(date -u)][---success---] The ${ENVIRONMENT} Postgres FQDN has been added to Key Vault [$KEYVAULTNAME]."
        else
            echo "[$(date -u)][---fail---] Failed to add the ${ENVIRONMENT} Postgres FQDN to Key Vault [$KEYVAULTNAME]."
            exit 2
        fi

        # Adding the Postgres User to Azure Key Vault.
        /usr/bin/az keyvault secret set \
        --name "${ENVIRONMENT}-postgres-username" \
        --vault-name "$KEYVAULTNAME" \
        --subscription "$AZURE_SUBSCRIPTION_ID" \
        --value "$POSTGRES_USER" > /dev/null 2>&0

        if [ $? -eq 0 ]; then
            echo "[$(date -u)][---success---] The ${ENVIRONMENT} Postgres Username has been added to Key Vault [$KEYVAULTNAME]."
        else
            echo "[$(date -u)][---fail---] Failed to add the ${ENVIRONMENT} Postgres Username to Key Vault [$KEYVAULTNAME]."
            exit 2
        fi

        # Adding the Postgres User Password to Azure Key Vault.
        /usr/bin/az keyvault secret set \
        --name "${ENVIRONMENT}-postgres-password" \
        --vault-name "$KEYVAULTNAME" \
        --subscription "$AZURE_SUBSCRIPTION_ID" \
        --value "$POSTGRES_PASSWORD" > /dev/null 2>&0

        if [ $? -eq 0 ]; then
            echo "[$(date -u)][---success---] The ${ENVIRONMENT} Postgres User's Password has been added to Key Vault [$KEYVAULTNAME]."
        else
            echo "[$(date -u)][---fail---] Failed to add the ${ENVIRONMENT} Postgres User's Password to Key Vault [$KEYVAULTNAME]."
            exit 2
        fi
```

## Conclusion

If you've been holding back from using Azure CLI in your Infrastructure-as-Code practice, here's another reason to give it a try. Hope you find it helpful.