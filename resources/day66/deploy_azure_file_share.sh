#!/bin/bash
##################################################################################################
#
# Name:             Deploy Azure File Share
#
# Author:           Pete Zerger 
# 
# Description:      This script is responsible for deploying an Azure File Share 
#
###################################################################################################

# Parse Script Parameters.
while getopts ":i:t:u:p:s:d:f:l:x:y:" opt; do
    case "${opt}" in
        i) # Azure Subscription ID.
             AZURE_SUBSCRIPTION_ID=${OPTARG}
             ;;
        t) # Azure Subscription Tenant ID.
             AZURE_SUBSCRIPTION_TENANT_ID=${OPTARG}
             ;;
        u) # Management Service Principal Username. 
             MGMT_SP_USERNAME=${OPTARG}
             ;;
        p) # Management Service Principal Password.
             MGMT_SP_PASSWORD=${OPTARG}
             ;;
#        s) # Storage Account Name.
#             STORAGE_ACCT=${OPTARG}
#             ;;
        s) # Azure Storage SKU
             STORAGE_SKU=${OPTARG}
             ;;
        d) # The naming prefix for associated K8s environment.
             ENVIRONMENT=${OPTARG}
             ;;
        f) # The purpose of the Azure File Share.
             FILE_SHARE_FUNCTION=${OPTARG}
             ;;
        l) # Azure Location.
             AZURE_LOCATION=${OPTARG}
             ;;
        x) # Azure File Share name.
             AZURE_FILE_SHARE=${OPTARG}
             ;;
        y) # Azure File Share Quota. 
             SHARE_QUOTA=${OPTARG}
             ;;
        \?) # Unrecognised option - show help.
            echo -e \\n"Option [-${BOLD}$OPTARG${NORM}] is not allowed. All Valid Options are listed below:"
            echo -e "-i AZURE_SUBSCRIPTION_ID                    - The Azure Subscription ID."
            echo -e "-t AZURE_SUBSCRIPTION_TENANT_ID             - The Azure Subscription Tenant ID."
            echo -e "-u MGMT_SP_USERNAME                         - Management Service Principal Username."
            echo -e "-p MGMT_SP_PASSWORD                         - Management Service Principal Password."
            echo -e "-s STORAGE_SKU                              - Azure Storage SKU : Standard_GRS or Premium_LRS"
            echo -e "-d ENVIRONMENT                              - The naming prefix for associated environment."
            echo -e "-f FILE_SHARE_FUNCTION                      - The purpose of the Azure File Share. Just a short user-defined code"
            echo -e "-l AZURE_LOCATION                           - The Azure Location where the File Share will be deployed."
            echo -e "-x AZURE_FILE_SHARE                         - Azure File Share name."
            echo -e "-y SHARE_QUOTA                              - Azure File Share Quota."
            echo -e "Script Syntax is shown below:"
            echo -e "./deploy_azure_file_share.sh -i {AZURE_SUBSCRIPTION_ID} -t {AZURE_SUBSCRIPTION_TENANT_ID} -a {AKS_ENGINE_VERSION} -u {MGMT_SP_USERNAME} -p {MGMT_SP_PASSWORD}  -s {STORAGE_SKU} -d {ENVIRONMENT} -f {FILE_SHARE_FUNCTION} -l {AZURE_LOCATION} -x {AZURE_FILE_SHARE} -y {SHARE_QUOTA}\\n"
            echo -e "An Example of how to use this script is shown below:"
            echo -e "./deploy_azure_file_share.sh -i 5345deaa-0037-4785-8ce9-7c6a3c4e5e7b -t e7453b1c-6356-4cc1-a495-d74eccd5e205 -u mysvcprin -p 'MyPassword!' -s Standard_GRS -d 'swdemo' -f pkgs -l 'eastus' -x 'swpgdemo' -y 5120 \\n"
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

if [ -z "${MGMT_SP_USERNAME}" ]; then
    echo "[$(date -u)][---fail---] Management Service Principal Username must be provided."
    exit 2
fi

if [ -z "${MGMT_SP_PASSWORD}" ]; then
    echo "[$(date -u)][---fail---] Management Service Principal Password must be provided."
    exit 2

if [ -z "${STORAGE_ACCOUNT}" ]; then
    echo "[$(date -u)][---fail---] The Postgres Azure Storage Account Name being created must be provided."
    exit 2
fi

if [ -z "${ENVIRONMENT}" ]; then
    echo "[$(date -u)][---fail---] The K8s naming prefix must be included."
    exit 2
fi

# if [ -z "${AZURE_FILE_RG}" ]; then
#    echo "[$(date -u)][---fail---] The Azure Resource Group must be included."
#    exit 2
# fi

if [ -z "${AZURE_LOCATION}" ]; then
    echo "[$(date -u)][---fail---] The Azure Location where to deploy the share must be provided."
    exit 2
fi

if [ -z "${AZURE_FILE_SHARE}" ]; then
    echo "[$(date -u)][---fail---] The Azure File Share Name must be provided."
    exit 2
fi

if [ -z "${SHARE_QUOTA}" ]; then
    echo "[$(date -u)][---fail---] The Azure File Share Quota must be provided."
    exit 2
fi

# Logging in to Azure as the Management Service Principal.
# /usr/bin/az login --service-principal -u "$MGMT_SP_USERNAME" -p $MGMT_SP_PASSWORD --tenant $AZURE_SUBSCRIPTION_TENANT_ID 
/usr/bin/az login --service-principal -u "http://$MGMT_SP_USERNAME" -p $MGMT_SP_PASSWORD --tenant $AZURE_SUBSCRIPTION_TENANT_ID # > /dev/null 2>&0

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

# Checking to see if the Resource Group already exists.
# /usr/bin/az group show --resource-group $AZURE_FILE_RG --subscription $AZURE_SUBSCRIPTION_IDc

AZURE_FILE_RG="azure-${ENVIRONMENT}-${FILE_SHARE_FUNCTION}-rg"

/usr/bin/az group show \
--resource-group $AZURE_FILE_RG \
--subscription $AZURE_SUBSCRIPTION_ID > /dev/null 2>&0

        if [ $? -eq 0 ]; then
            echo "[$(date -u)][---info---] Resource Group [$AZURE_FILE_RG] already exists."
        else
            echo "[$(date -u)][---info---] Resource Group [$AZURE_FILE_RG] not found."

        # Create a resource group
        # az group create --name $AZURE_FILE_RG --location $AZURE_LOCATION > /dev/null 2>&0

        az group create \
        --name $AZURE_FILE_RG \
        --location $AZURE_LOCATION > /dev/null 2>&0

        if [ $? -eq 0 ]; then
        echo "[$(date -u)][---success---] Created the Resource Group [$AZURE_FILE_RG] for the storage acct."
    else
        echo "[$(date -u)][---fail---] Failed to create the Resource Group [$AZURE_FILE_RG] for the storage acct."
        exit 2
    fi
fi

#####################################
# Step 2: Create the Storage Account 
#####################################

# Set unique storage account 
STORAGE_ACCT="aimshare$FILE_SHARE_FUNCTION$ENVIRONMENT"

# Checking to see if the Storage Account already exists in the Azure Subscription.

POSTGRES_STORAGE_ACCOUNT_CHECK=$(/usr/bin/az storage account list | jq --arg POSTGRES_STORAGE_ACCOUNT "$STORAGE_ACCT" '.[] | select(.name == $POSTGRES_STORAGE_ACCOUNT).name' | tr -d '"')

if [ -z "${POSTGRES_STORAGE_ACCOUNT_CHECK}" ]; then
    echo "[$(date -u)][---info---] The Storage Account [$STORAGE_ACCT] was not found in the Azure Subscription."

    # Creating the Storage Account in the Resource Group.
    # /usr/bin/az storage account create --name $STORAGE_ACCT --resource-group $AZURE_FILE_RG --sku Standard_LRS --encryption-services blob --https-only true > /dev/null 2>&0

    # 9/5/2019 - STORAGE_SKU is either Standard_GRS or Premium_LRS for now
    KIND_ARG=""
    ENCRYPTION_SERVICES_ARG="blob"
    if [ "$STORAGE_SKU" == "Premium_LRS" ]; then
        KIND_ARG="--kind FileStorage"
        ENCRYPTION_SERVICES_ARG="file"
    fi

    echo "[$(date -u)][---info---] /usr/bin/az storage account create --name $STORAGE_ACCT --resource-group $AZURE_FILE_RG --sku $STORAGE_SKU --encryption-services $ENCRYPTION_SERVICES_ARG --https-only true $KIND_ARG"

    /usr/bin/az storage account create \
    --name $STORAGE_ACCT \
    --resource-group $AZURE_FILE_RG \
    --sku $STORAGE_SKU \
    --encryption-services $ENCRYPTION_SERVICES_ARG \
    --https-only true $KIND_ARG > /dev/null 2>&0

    if [ $? -eq 0 ]; then
        echo "[$(date -u)][---info---] Created the [$STORAGE_SKU] Storage Account [$STORAGE_ACCT] in File Share Resource Group [$AZURE_FILE_RG]."
    else
        echo "[$(date -u)][---info---] Failed to create the [$STORAGE_SKU] Storage Account [$STORAGE_ACCT] in File Share Resource Group [$AZURE_FILE_RG]."
        exit 2
    fi

    # Retrieving the Storage Account Primary Key.
    # https://docs.microsoft.com/en-us/azure/virtual-machines/linux/mount-azure-file-storage-on-linux-using-smb#get-the-storage-key
    # STORAGE_ACCOUNT_PRIMARY_KEY=$(az storage account keys list --resource-group $AZURE_FILE_RG --account-name $STORAGE_ACCT | jq '.[0] |select(.value).value')

    STORAGE_ACCOUNT_PRIMARY_KEY=$(az storage account keys list \
    --resource-group $AZURE_FILE_RG --account-name $STORAGE_ACCT \
    | jq '.[0] | select(.value).value')

    if [ $? -eq 0 ]; then
        echo "[$(date -u)][---info---] Retrieved the Primary Storage Account Key from the Storage Account [$STORAGE_ACCT]."
        #echo "Storage key is [$STORAGE_ACCOUNT_PRIMARY_KEY]"
    else
        echo "[$(date -u)][---info---] Failed to retrieve the Primary Storage Account Key from the Storage Account [$STORAGE_ACCT]."
        exit 2
    fi

else
    echo "[$(date -u)][---info---] The Storage Account [$STORAGE_ACCT] already exists in the Azure Subscription."
fi

####################################################
# Step 3: Create the Azure File Share
####################################################

# Create the Storage Account Connection String 
current_env_conn_string=$(az storage account show-connection-string \
-n $STORAGE_ACCT -g $AZURE_FILE_RG \
--query 'connectionString' -o tsv)

        if [[ $current_env_conn_string == "" ]]; then  
            echo "[$(date -u)][---info---] Couldn't retrieve the connection string."
        else 
            echo "[$(date -u)][---info---] Retrieved the file share connection string."
        fi

# Checking to see if the Azure File Share already exists.
# az storage share show -n $AZURE_FILE_SHARE --connection-string "$current_env_conn_string"
AZURE_FILE_SHARE_CHECK=$(/usr/bin/az storage share exists \
--account-name $AZURE_FILE_RG -n $AZURE_FILE_SHARE \
--connection-string "$current_env_conn_string" | grep -ic "true")
    
    if  [[ $AZURE_FILE_SHARE_CHECK -gt 0 ]]; then
            echo "[$(date -u)][---info---] File Share [$AZURE_FILE_SHARE] already exists."
        else
            echo "[$(date -u)][---info---] File Share [$AZURE_FILE_SHARE] not found."

        az storage share create \
        --name $AZURE_FILE_SHARE \
        --connection-string "$current_env_conn_string" \
        --quota 5120 > /dev/null 2>&0

        if [ $? -eq 0 ]; then
                 echo "[$(date -u)][---success---] Created the File Share [$AZURE_FILE_SHARE] successfully."
             else
                 echo "[$(date -u)][---fail---] Failed to create the Resource Group [$AZURE_FILE_SHARE]."
                 exit 2
        fi
     fi

########################################################
# Step 4: Add storage connection info to Azure Key Vault
########################################################

        # Retrieve the access key 
        KEYVAULTNAME="$ENVIRONMENT-keyvault"
        STORAGE_ACCOUNT_PRIMARY_KEY=$(az storage account keys list --resource-group $AZURE_FILE_RG --account-name $STORAGE_ACCT | jq '.[0] | select(.value).value')


        # Adding the Azure File Share User to Azure Key Vault.

        /usr/bin/az keyvault secret set \
        --name "aim-${ENVIRONMENT}-${FILE_SHARE_FUNCTION}-storage-acct" \
        --vault-name "$KEYVAULTNAME" \
        --subscription "$AZURE_SUBSCRIPTION_ID" \
        --value "$STORAGE_ACCT" > /dev/null 2>&0

        if [ $? -eq 0 ]; then
            echo "[$(date -u)][---success---] The ${ENVIRONMENT} ${FILE_SHARE_FUNCTION} storage acct name has been added to Key Vault [$KEYVAULTNAME]."
        else
            echo "[$(date -u)][---fail---] Failed to add the ${ENVIRONMENT} ${FILE_SHARE_FUNCTION} storage acct name to Key Vault [$KEYVAULTNAME]."
            exit 2
        fi

        # Adding the Azure File Share Access Key (password) to Azure Key Vault.

        /usr/bin/az keyvault secret set \
        --name "aim-${ENVIRONMENT}-${FILE_SHARE_FUNCTION}-storage-access-key" \
        --vault-name "$KEYVAULTNAME" \
        --subscription "$AZURE_SUBSCRIPTION_ID" \
        --value "$STORAGE_ACCOUNT_PRIMARY_KEY" > /dev/null 2>&0
        

        if [ $? -eq 0 ]; then
            echo "[$(date -u)][---success---] The $ENVIRONMENT ${FILE_SHARE_FUNCTION} storage access key has been added to Key Vault [$KEYVAULTNAME]."
        else
            echo "[$(date -u)][---fail---] Failed to add the $ENVIRONMENT ${FILE_SHARE_FUNCTION} storage access key to Key Vault [$KEYVAULTNAME]."
            exit 2
        fi
