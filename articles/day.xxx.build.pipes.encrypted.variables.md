# Day XXX - Build Pipelines, using Encrypted Variables

```bash
AZURE_SP=$(/usr/bin/az ad sp create-for-rbac \
--role "contributor" \
--name "encrypted-variables-and-key-vault-linux" \
--years 3)
```
