












Run the following command to create a Service Principal to use with this demonstration.

```bash
AZURE_SP=$(/usr/bin/az ad sp create-for-rbac \
--role "contributor" \
--name "encrypted-variables-and-key-vault" \
--years 3)
```

Azure CLI task name is: retrieve-storage-account-key-using-iam

Run the following command to list the Primary Key of the Storage Account.

```bash
# Displaying the Storage Account Primary Key Value using IAM Permissions by adding the Service Principal to the Storage Account.
az storage account keys list \
--account-name encryptvardemo \
--query [0].value \
--output tsv
```

## one