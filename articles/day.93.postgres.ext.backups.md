# Day 93 - Long-term Backup Retention for Azure Database for PostgreSQL

The Azure Database for PostgreSQL has a built-in backup feature, but is only configurable for 7-35 day retention. Here's an ad-hoc solution I built for microservices environments where I have VMs running for various purposes, such as hosting Docker or Kubernetes based workloads. It takes geo-redundancy into account (important for disaster recovery). It also verifies the integrity of cloud copy of backup through MD5 hash comparison, which is easier said than done due to the format of MD5 hashes stored in Azure vs the Linux file system.

In this article:

[Solution description](#solution-description) </br>
[Restoring backups](#restoring-backups) </br>
[How the script works](#how-the-script-works) </br>
[Instructions for use](#Instructions-for-use) </br>
[To add or remove database from backups](#to-add-or-remove-database-from-backups) </br>
[Full Script](#full-script) </br>


# Solution description

The `postgres_backups.sh` script, designed to run from an Azure Linux VM, backs up Azure Database for PostgreSQL databases to geo-redundant Azure blob storage to facilitate local database restore or service recovery in a remote Azure datacenter. For example, if using a GRS storage account in the East US datacenter, the paired region is West US, as detailed in "Business continuity and disaster recovery (BCDR): Azure Paired Regions" at https://docs.microsoft.com/en-us/azure/best-practices-availability-paired-regions.

## Restoring backups

Backups created with this script can be restored to PostgreSQL using the native **pg_restore** utility.

## How the script works:

The current version of the script performs all of the following high-level functions:

- **Verify necessary tools are present**
  - Verify **Azure CLI** is installed
  - Verify **blobxfer** utility is installed
  - Verify **postgres client tools** are installed
- **Retrieve secrets.** Retrieve necessary secrets from Azure Key Vault.
- **Perform backups.** Perform full backup of all PostgreSQL databases indicated in the script.
- **Capture local MD5 hash.** Captures the MD5 hash of the local backup file.
- **Upload backup.** Uploads backup to geo-redundant blob storage in customer Azure subscription.
- **Retreive and convert remote MD5 hash.** Retrieve MD5 hash from Azure file metadata, convert to hex format, compare to local MD5 hash.
- **Upload blobxfer log.** Copy the blobxfer log to Azure blob storage for easy reference.
- **Cleanup.** When all uploads are complete, remove local backup files and logs.

## Instructions for use

The required parameters are:

 - **Customer code.** 5-digit code used to identify customer, determined when environment was provisioned.
 - **Service principal name.**  Service principal created for environment provisioning.
 - **Service principal password.** Password for the aforementioned service principal.
 - **Azure AD Tenant ID.** The guid of the Azure AD environment, which in this case is the shared management instance.

**SYNTAX**

`postgres_backup.sh -i {AZURE_SUBSCRIPTION_ID} \`

`-t {AZURE_SUBSCRIPTION_TENANT_ID} \`

`-u {MGMT_SP_USERNAME} \`

`-p {MGMT_SP_PASSWORD} \`

`-c {CUSTOMER}`

## To add or remove database from backups

To add or remove databases from the backup, browse to the "DB backup and upload" section of the script (currently around line 363).

## Full Script  

The script is included below and in the Day 93 folder in the Resources directory

``` Bash
#!/bin/sh    
###########################################################################
#    
# NAME: postgres_backup.sh 
# 
# AUTHOR: Pete Zerger 
# 
# DESCRIPTION: This script uses pg_dump to perform full database backups
#              and uploads them to geo-redundant Azure blob storage. Uses
#              blobxfer, a native MSFT utility to upload files to blob
#              storage with the data movement libraries. It also verifies
#              integrity of cloud copy of backup through MD5 hash comparison
#              to the local version 
#
# NOTES: Run the script without parameters to get the syntax.
#        Look at how we're deriving Azure Key Vault name in 'Base Variables' section
#
# ------------------------------------------


# Parse Script Parameters.
while getopts ":i:t:u:p:c:-:" opt; do
    case "${opt}" in
        i) # Azure Subscription ID.
             AZURE_SUBSCRIPTION_ID=${OPTARG}
             ;;
        t) # Azure Subscription Tenant ID.
             AZURE_SUBSCRIPTION_TENANT_ID=${OPTARG}
             ;;
        u) # Management Service Principal Username. This is used for managing a variety of resources in an Azure Subscription.
             MGMT_SP_USERNAME=${OPTARG}
             ;;
        p) # Management Service Principal Password.
             MGMT_SP_PASSWORD=${OPTARG}
             ;;
        c) # 5-character environment identification code 
             ENVIRONMENT=${OPTARG}
             ;;
        \?) # Unrecognised option - show help.
            echo -e \\n"Option [-${BOLD}$OPTARG${NORM}] is not allowed. All Valid Options are listed below:"
            echo -e "-i AZURE_SUBSCRIPTION_ID                    - The Azure Subscription ID."
            echo -e "-t AZURE_SUBSCRIPTION_TENANT_ID             - The Azure Subscription Tenant ID."
            echo -e "-u MGMT_SP_USERNAME                         - Management Service Principal Username."
            echo -e "-p MGMT_SP_PASSWORD                         - Management Service Principal Password."
            echo -e "--ENVIRONMENT <id>                          - 5-character name of the environment."
            echo -e "Script Syntax is shown below:"
            echo -e "./postgres_backups.sh -i {AZURE_SUBSCRIPTION_ID} -t {AZURE_SUBSCRIPTION_TENANT_ID} -u {MGMT_SP_USERNAME} -p {MGMT_SP_PASSWORD} -c {ENVIRONMENT}\\n"
            echo -e "An Example of how to use this script is shown below:"
            echo -e "./postgres_backups.sh -i xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx -t xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx -u sp_acct -p MyPassword -c 'test5' \\n"
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
    echo "[$(date -u)][---fail---]  Management Service Principal Password must be provided."
    exit 2
fi

if [ -z "${ENVIRONMENT}" ]; then
    echo "[$(date -u)][---fail---] Environment name for environment being created must be provided."
    exit 2
fi

######################
# Base variables 
######################

# Azure Key Vault name
KEYVAULTNAME="$ENVIRONMENT-KEYVAULT"

##############################################################
# Configure script logging (echo to console and send to log )
##############################################################

# Log Location on Server.
BKUP_DATE=`date +"%Y%m%d_%H%M"`
LOG_LOCATION='/usr/scripts/logs'
LOG_NAME="postgres_backups_$BKUP_DATE.log"

# Make sure log directory exists 

#    if [ [ -d "$LOG_LOCATION" ] ]; then
    if [ -d "$LOG_LOCATION" ]; then
        echo "[$(date -u)][---success---] Log directory exists."
    else
        echo "[$(date -u)][---fail---] Log directory does not exist. Attempting to create now."
        mkdir "/usr/scripts"
        mkdir "/usr/scripts/logs"
    
        # Check if creation was successful
            if [ -d "$LOG_LOCATION" ]; then
                echo "[$(date -u)][---success---] Log directory exists. Creation successful"
            else
                echo "[$(date -u)][---fail---] Log directory does not exist. Exiting"
                exit 2
            fi

    fi

########################################################
# Verify Azure CLI is present, login as service principal
########################################################

# Checking to see if Azure CLI is installed.
if [ -e "/usr/bin/az" ]; then
    echo "[$(date -u)][---info---] Azure CLI is already installed."
else
    echo "[$(date -u)][---info---] Azure CLI is not installed."

    # Installing the Azure CLI.
    AZ_REPO=$(lsb_release -cs) && \
    echo "deb [arch=amd64] https://packages.microsoft.com/repos/azure-cli/ $AZ_REPO main" | \
    sudo tee /etc/apt/sources.list.d/azure-cli.list && \
    curl -s -L https://packages.microsoft.com/keys/microsoft.asc | sudo apt-key add - && \
    sudo apt-get install -y apt-transport-https && \
    sudo apt-get update && \
    sudo apt-get install -y azure-cli > /dev/null 2>&0

    if [ $? -eq 0 ]; then
        echo "[$(date -u)][---success---] Installed Azure CLI."
    else
        echo "[$(date -u)][---fail---] Failed to install Azure CLI."
        exit 2
    fi
fi

# Logging in to Azure as the Management Service Principal.
/usr/bin/az login \
--service-principal \
-u "http://$MGMT_SP_USERNAME" \
-p "$MGMT_SP_PASSWORD" \
--tenant "$AZURE_SUBSCRIPTION_TENANT_ID" > /dev/null 2>&0

if [ $? -eq 0 ]; then
    echo "[$(date -u)][---success---] Logged into Azure as the Management Service Principal [$MGMT_SP_USERNAME]."
else
    echo "[$(date -u)][---fail---] Failed to login to Azure as the Management Service Principal [$MGMT_SP_USERNAME]."
    exit 2
fi

if [ -f SSH-key-pair.pem ]; then
    echo "[$(date -u)][---info---] Updating permissions on SSH-key-pair ..."
    chmod 400 SSH-key-pair.*
    if [ $? -ne 0 ]; then
        echo "[$(date -u)][---fail---] Unable to update SSH-key-pair file permissions to 400 ..."
        exit 2
    fi
fi


####################################################
# Lookup secrets in AKV for connecting to PostgreSQL
####################################################

# Retrieve Postgres FQDN (use with pgdump)
PG_FQDN_LABEL="$ENVIRONMENT-postgres-fqdn"
PG_FQDN=$(/usr/bin/az keyvault secret show --name "$PG_FQDN_LABEL" --vault-name "$KEYVAULTNAME" --query value --output tsv)

    if [ $? -eq 0 ]; then
        echo "[$(date -u)][---success---] Retrieved Postgres servername successfully."
    else
        echo "[$(date -u)][---fail---] Failed to retrieve Postgres servername."
        exit 2
    fi

# Retrieve Postgres User (use with pgdump)
PG_USER_LABEL="$ENVIRONMENT-postgres-username"

PG_USER=$(/usr/bin/az keyvault secret show --name "$PG_USER_LABEL" --vault-name "$KEYVAULTNAME" --query value --output tsv)

    if [ $? -eq 0 ]; then
        echo "[$(date -u)][---success---] Retrieved Postgres username successfully."
    else
        echo "[$(date -u)][---fail---] Failed to retrieve Postgres username."
        exit 2
    fi

# Retrieve Postgres Password (use with pgdump)
PG_PASSWORD_LABEL="$ENVIRONMENT-postgres-password"

PG_PASSWORD=$(/usr/bin/az keyvault secret show --name "$PG_PASSWORD_LABEL" --vault-name "$KEYVAULTNAME" --query value --output tsv)

    if [ $? -eq 0 ]; then
        echo "[$(date -u)][---success---] Retrieved Postgres password successfully."
    else
        echo "[$(date -u)][---fail---] Failed to retrieve Postgres password."
        exit 2
    fi

####################################################
# Lookup secrets for connecting to BCDR blob storage
####################################################

BCDR_STORAGE_ACCT_LABEL="$ENVIRONMENT-bcdr-storage-acct"
BCDR_STORAGE_ACCT=$(/usr/bin/az keyvault secret show --name "$BCDR_STORAGE_ACCT_LABEL" --vault-name "$KEYVAULTNAME" --query value --output tsv)

    if [ $? -eq 0 ]; then
        echo "[$(date -u)][---success---] Retrieved BCDR blob storage name successfully."
    else
        echo "[$(date -u)][---fail---] Failed to retrieve BCDR blob storage name."
        exit 2
    fi

BCDR_STORAGE_ACCESS_KEY_LABEL="$ENVIRONMENT-bcdr-storage-access-key"
BCDR_STORAGE_ACCESS_KEY=$(/usr/bin/az keyvault secret show --name "$BCDR_STORAGE_ACCESS_KEY_LABEL" --vault-name "$KEYVAULTNAME" --query value --output tsv)
echo "storage access key value is $BCDR_STORAGE_ACCESS_KEY"
    if [ $? -eq 0 ]; then
        echo "[$(date -u)][---success---] Retrieved BCDR blob storage access key successfully."
    else
        echo "[$(date -u)][---fail---] Failed to retrieve BCDR blob storage access key."
        exit 2
    fi

############################
# Verify blobxfer is present 
############################

if [ -e "/usr/bin/blobxfer" ]; then
    echo "[$(date -u)][---info---] blobxfer is already installed."
else
    echo "[$(date -u)][---info---] blobxfer is not installed."

    # Installing blobxfer 
    cd /usr/bin 
    wget https://github.com/Azure/blobxfer/releases/download/1.8.0/blobxfer-1.8.0-linux-x86_64
    mv blobxfer-1.8.0-linux-x86_64 blobxfer
    chmod +x blobxfer

    if [ $? -eq 0 ]; then
        echo "[$(date -u)][---success---] Installed blobxfer."
    else
        echo "[$(date -u)][---fail---] Failed to install blobxfer."
        exit 2
    fi
fi


############################
# Verify pg_dump is present 
############################

if [ -e "/usr/bin/pg_dump" ]; then
    echo "[$(date -u)][---info---] pg_dump is already installed."
else
    echo "[$(date -u)][---info---] pg_dump is not installed."

    # Installing pg_dump 
    apt-get --assume-yes install postgresql-client-10

    if [ $? -eq 0 ]; then
        echo "[$(date -u)][---success---] Installed pg_dump."
    else
        echo "[$(date -u)][---fail---] Failed to install pg_dump."
        exit 2
    fi
fi


###########################################
# Backup DBs and copy to Azure blob storage
###########################################

pgbackup() { 

  hostname="$1.postgres.database.azure.com"
  # dbname='postgres'
  dbname="$2"
  
  # username='postgres@pzpzp'
  username=$3

  # Dump DBs
  date=`date +"%Y%m%d_%H%M%N"`
  # filename="/tmp/${ENVIRONMENT}_${dbname}_${date}.sql"
  filename="${ENVIRONMENT}_${dbname}_${date}.sql"

  # This worked to eliminate password prompt in testing
 PGPASSWORD="$MGMT_SP_PASSWORD" pg_dump -h $hostname -p 5432 -U $username -F c -b -v -f "/tmp/$filename" $dbname

  if [ $? -eq 0 ]; then
        echo "[$(date -u)][---success---] Backup job successful."
    else
        echo "[$(date -u)][---fail---] Backup job failed."
        exit 2
  fi

# exit 0

}

###########################################
# Upload the backup file to Azure 
###########################################

uploadbackup(){
  file_name=$1
  storage_acc_name=$2
  saskey=$3
  saskey=$(eval echo $saskey)
  LOCAL_HASH=`md5sum "/tmp/$file_name" | cut -d " " -f1`
  BLOBXFER_LOG="blobxfer_${date}.log"
  printf "FILE_NAME: ${YELLOW} $file_name ${NC}\n"
  printf "STORAGE_ACCOUNT_NAME: ${YELLOW} $storage_acc_name ${NC}\n"
  printf "SAS_KEY: ${YELLOW} $saskey ${NC}\n"
  printf "MD5 value before Transfer: ${YELLOW} $LOCAL_HASH ${NC}\n"

 blobxfer upload --storage-account $storage_acc_name --sas $saskey --remote-path pgbackups --local-path "/tmp/$file_name" --file-md5 --no-recursive --log-file /tmp/$BLOBXFER_LOG

 ##############################
 # Backup file integrity check
 ############################## 

  MD5_AZURE=`az storage blob show -c pgbackups --name $file_name --account-name $storage_acc_name --account-key "$saskey" --query "properties.contentSettings.contentMd5" -o tsv`
  

  # ------ Begin CONVERT AZURE MD5 HASH TO HEX FOR COMPARISON ------

  AZURE_HASH="$(echo -n $MD5_AZURE | base64 -d | od -t x1 -An)"
  echo "Azure hash is $AZURE_HASH"
  # Trim white spaces and store this in your variable. 
  AZURE_HASH_HEX="$(echo "${AZURE_HASH}" | tr -d '[:space:]')" 

  # ------ End CONVERT MD5 HASH TO HEX FOR COMPARISON ------

    if [ $? -eq 0 ]; then
        echo "[$(date -u)][---success---] DB backup file $dbname upload successful."
    else
        echo "[$(date -u)][---fail---] DB backup file $dbname upload failed."
        exit 2
    fi

    # File upload successful. Now compare MD5 file hashes. 
    if [ "$LOCAL_HASH" = "$AZURE_HASH_HEX" ]; then
    echo "strings match!"
    echo "Local hash is $LOCAL_HASH and Azure hash is $AZURE_HASH_HEX"
else 
    echo "strings don't match!"
    echo "Local hash is $LOCAL_HASH and Azure hash is $AZURE_HASH_HEX"
fi 

# exit 0

}

########################
# DB backup and upload 
########################

# Backup ALL Postgres DBs 
# Params: hostname=$1   dbname=$2   username=$3
pgbackup $ENVIRONMENT  'postgres'  "postgres@$ENVIRONMENT"
uploadbackup "$filename" "$BCDR_STORAGE_ACCT" $BCDR_STORAGE_ACCESS_KEY

pgbackup $ENVIRONMENT  'keycloak'  "postgres@$ENVIRONMENT"
uploadbackup "$filename" "$BCDR_STORAGE_ACCT" $BCDR_STORAGE_ACCESS_KEY

pgbackup $ENVIRONMENT  'kong'  "postgres@$ENVIRONMENT"
uploadbackup "$filename" "$BCDR_STORAGE_ACCT" $BCDR_STORAGE_ACCESS_KEY


##########
# Cleanup
##########

# Finally, upload the blobxfer log file for this run 
blobxfer upload --storage-account $storage_acc_name --sas $saskey --remote-path pgbackups --local-path "/tmp/$BLOBXFER_LOG" --file-md5 --no-recursive

# delete the backups from the local drive
rm -rf /tmp/$ENVIRONMENT*

# delete blobxfer log from the local drive
rm -rf /tmp/$BLOBXFER_LOG

```

## Conclusion

I hope this solution gives you a useful starting point for implementing extended data retention in your Azure Database for PostgreSQL use cases. Remember, if you have a question or an issue, you can open an issue here on the "100 Days" repo.
