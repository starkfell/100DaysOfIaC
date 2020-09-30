## Day 46 -  A Pipeline-friendly Script for CosmosDB with Mongo API

With CosmosDB, Microsoft offers a Mongo API that enables apps to communicate to CosmosDB like they would a MongoDB cluster.
We've talked repeatedly about the flexibility of using Azure CLI (bash) in your day-to-day, non-prod releases. Today, we offer a script, designed to run in a release pipeline in Azure Pipelines, and performs the following configuration of your CosmosDB with Mongo API instance, including:

- Logs in as a service principal
- Switches context to the Azure sub
- Checks for the prerequisites needed on the build agent
- Deploys the CosmosDB instance with Mongo API
- Sets the SKU (cluster size)
- Sets whitelisted IP addresses for remote access
- Deploys the databases with the capacity (request units) you specify

You'll see a a couple of properties that remain hard-coded, as that was fine in my environment. Now, you have a rich sample that gives you a running start, and you can parameterize even further.

***
SPONSOR: Need to stop and start your development VMs on a schedule? The Azure Resource Scheduler let's you schedule up to 10 Azure VMs for FREE! Learn more [HERE](https://azuremarketplace.microsoft.com/en-us/marketplace/apps/lumagatena.resourcescheduler?tab=Overview)
***

## What's missing from this sample?

What's left out is all the Azure Key Vault integration, which I have removed to simplify your consumption. I leverage key vault heavily to store secrets, such the Azure service principal used deploy, and the Mongo API endpoint my apps will use to talk to the DB. We have many Azure Key Vault script samples in this series that will help you add what you need.

The other thing missing is the answer to the question "How do I use this in Azure Pipelines?" I run this from a single stage release pipeline, variables stored as release variables, with some variables designated as overridable at deploy time

## SAMPLE SCRIPT

The script, and command line syntax are shown here, well-commented so you know what's happening at every stage. The full script is shown below, as well as in the [day46](../resources/day46) folder in the resources in this Git repository.

**SYNTAX:**

``` Bash
./createmongo.sh -i 0b62f50c-c15a-40e2-b1ab-7ac2596a1d74 -t cf5b57b5-3bce-46f1-82b0-396341247817 \
-l eastus -r my-cosmos-rg -u iac-sp -p 'myspsecret' -k MongoDB -v mymongoacct -x 73.206.30.142
```

``` Bash
#!/bin/bash

#########################################################################################################
#
# Name:             Create CosmosDB with Mongo API instance and databases
#
# Author:           Pete Zerger  
# 
# Description:      This script is responsible for deploying an Azure Cosmos DB instance.
#
# Sample:           see parameter documentation and example at the head of the script below.
#
#########################################################################################################

# Parse Script Parameters.
while getopts ":i:t:l:r:u:p:d:x:v:k:b:y:" opt; do
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
        r) # The Resource Group name for the CosmosDB & related resources.
             MONGO_RG=${OPTARG}
             ;;
        u) # Management Service Principal Username. This is used for managing CosmosDB instances 
             MGMT_SP_USERNAME=${OPTARG}
             ;;
        p) # Management Service Principal Password.
             MGMT_SP_PASSWORD=${OPTARG}
             ;;
        x) # Allowed IP addresses (through firewall).
             ALLOWED_IPS=${OPTARG}
             ;;
        v) # Mongo account name.
             ACCT_NAME=${OPTARG}
             ;;
        k) # Cosmos DB SKU (type).
             SKU_NAME=${OPTARG}
             ;;
        \?) # Unrecognised option - show help.
            echo -e \\n"Option [-${BOLD}$OPTARG${NORM}] is not allowed. All Valid Options are listed below:"
            echo -e "-i AZURE_SUBSCRIPTION_ID                    - The Azure Subscription ID."
            echo -e "-t AZURE_SUBSCRIPTION_TENANT_ID             - The Azure Subscription Tenant ID."
            echo -e "-l AZURE_LOCATION                           - The Azure Location where the File Share will be deployed."
            echo -e "-r MONGO_RG                                 - Cosmos (Mongo) resource group name"
            echo -e "-u MGMT_SP_USERNAME                         - Management Service Principal Username. This is used for managing all Mongo DBs in an Azure Subscription."
            echo -e "-p MGMT_SP_PASSWORD                         - Management Service Principal Password."
            echo -e "-x ALLOWED_IPS                               - IP addresses allowed to access ."
            echo -e "-v ACCT_NAME                                - Mongo account name."
            echo -e "-k SKU_NAME                                 - The type of Cosmos DB to create (MongoDB, Parse, GlobalDocumentDB)"
            echo -e "Script Syntax is shown below:"
            echo -e "./createmongo.sh -i {AZURE_SUBSCRIPTION_ID} -t {AZURE_SUBSCRIPTION_TENANT_ID} -l {AZURE_LOCATION} -r {MONGO_RG} -u {MGMT_SP_USERNAME} -p {MGMT_SP_PASSWORD} -k {SKU_NAME} -v {MONGO_VERSION} -x {ALLOWED_IPS}"
            echo -e "An Example of how to use this script is shown below:"
            echo -e "./createmongo.sh -i 0b62f50c-c15a-40e2-b1ab-7ac2596a1c85 -t cf5b57b5-3bce-46f1-82b0-396341247458 -l eastus -r my-cosmos-rg -u mysvcprcpl -p 'myspsecret' -k MongoDB -v mymongoacct -x 73.206.30.153 \\n"
            exit 2
            ;;
    esac
done
shift $((OPTIND-1))


# Logging in to Azure as the Management Service Principal.
/usr/bin/az login --service-principal -u "http://$MGMT_SP_USERNAME" --p $MGMT_SP_PASSWORD --tenant $AZURE_SUBSCRIPTION_TENANT_ID # > /dev/null 2>&0

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
--resource-group $MONGO_RG \
--subscription $AZURE_SUBSCRIPTION_ID > /dev/null 2>&0

    if [ $? -eq 0 ]; then
            echo "[$(date -u)][---info---] Resource Group [$MONGO_RG] already exists."
        else
            echo "[$(date -u)][---info---] Resource Group [$MONGO_RG] not found."

        az group create \
        --name $MONGO_RG \
        --location $AZURE_LOCATION > /dev/null 2>&0

        if [ $? -eq 0 ]; then
        echo "[$(date -u)][---success---] Created the Resource Group [$MONGO_RG] for the Cosmos (Mongo) instance."
        else
        echo "[$(date -u)][---fail---] Failed to create the Resource Group [$MONGO_RG] for the Cosmos (Mongo) instance."
        exit 2
        fi
    fi


###############################################
# Step 2: Deploy the Cosmos Mongo API Instance 
###############################################

az cosmosdb show \
    --name $ACCT_NAME \
    --resource-group $MONGO_RG > /dev/null 2>&0

    if [ $? -eq 0 ]; then
            echo "[$(date -u)][---info---] Cosmos DB account [$ACCT_NAME] already exists."
        else
            echo "[$(date -u)][---info---] Cosmos DB account [$ACCT_NAME] not found."

# Create a MongoDB API Cosmos DB account with consistent prefix (Local) consistency and multi-master enabled
az cosmosdb create \
    --resource-group $MONGO_RG \
    --name $ACCT_NAME \
    --kind MongoDB \
    --locations "$AZURE_LOCATION"=0 \
    --default-consistency-level "ConsistentPrefix" \
    --kind $SKU_NAME \
    --ip-range-filter $ALLOWED_IPS \
    --enable-multiple-write-locations true > /dev/null 2>&0

        if [ $? -eq 0 ]; then
        echo "[$(date -u)][---success---] Created Cosmos DB account [$ACCT_NAME] for the Cosmos DB instance."
        else
        echo "[$(date -u)][---fail---] Failed to create Cosmos DB account [$ACCT_NAME] for the Cosmos DB instance."
        exit 2
        fi
    fi

###############################################
# Step 4: Deploy MongoDB databases 
###############################################

    # Mongo URL 
      MONGO_URL="https://$ACCT_NAME.documents.azure.com:443/"

# This function will create the databse if it does not exist.
  createdb() {

    EXISTS=$(az cosmosdb database exists --resource-group $MONGO_RG --name $ACCT_NAME --db-name $1)

        if [ $EXISTS = "true" ]; then
                echo "the value of 'EXISTS' is $EXISTS"
                echo "[$(date -u)][---info---] Cosmos DB [$1] exists is true."
            else
                echo "the value of 'EXISTS' is $EXISTS"
                echo "[$(date -u)][---info---] Cosmos DB [$1] exists is false. Creating DB"
                # Create a database 
                az cosmosdb database create --key $PRIMARY_ACCESS_KEY \
                --url-connection $MONGO_URL \
                --resource-group $MONGO_RG \
                --name $ACCT_NAME \
                --db-name $1 \
                --throughput $2 > /dev/null 2>&0
                echo "$1 creation complete."
        fi 
    }

# Call the function to create the database 
# Pass database names and desired throughput (Request Units/sec)
createdb 'mydb1' '3000'
createdb 'mydb2' '3000'
```

## Conclusion

If you've been holding back from using Azure CLI in your Infrastructure-as-Code practice, here's another reason to give it a try. Hope you find it helpful.