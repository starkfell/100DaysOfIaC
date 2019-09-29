# Day 19 - Azure CLI Logging in Azure Build Pipelines, variable evaluation (Linux Edition)

In today's article we are going to go over how exit codes can affect the behavior of your Azure Build Pipelines when using bash scripts in the Azure CLI tasks.

The script below is going to be focus of today's topic and is by design supposed to fail.

```bash
#!/bin/bash

SHOW_GROUP=$(az group show 2>&1)

# Variation 1 - Check Exit Code of the previous command.
if [ $? -eq 0 ]; then
    echo "[---success---] Azure CLI command ran as intended."
else
    echo "[---fail------] Azure CLI command failed."
    echo "[---fail------] $SHOW_GROUP."
fi

# Variation 2 - Check the contents of the Variable.
if [[ $SHOW_GROUP =~ "ERROR" ]]; then
    echo "[---fail------] There was problem running the command."
    echo "[---fail------] echo "$SHOW_GROUP"
fi
```
