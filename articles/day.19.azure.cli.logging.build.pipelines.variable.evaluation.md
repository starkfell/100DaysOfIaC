# Day 19 - Azure CLI Logging in Azure Build Pipelines, variable evaluation (Linux Edition)

In today's article we are going to go over evaluating variables in bash script(s) to manipulate the output of your Azure Build Pipelines in Azure CLI tasks.

We are going to be focusing on the same script that was used in **[Day 18](../articles/day.18.azure.cli.logging.build.pipelines.redirects.exit.codes.md)** with some slight modifications.

```bash
#!/bin/bash
SHOW_GROUP=$(az group show 2>&1)

# Variation 2 - Check the contents of the Variable.
if [[ $SHOW_GROUP =~ "error" ]]; then
    echo "[---fail------] There was problem running the command."
    echo "[---fail------] $SHOW_GROUP"
    exit 2
fi
```

First off, if you run the command that is encapsulated in the **SHOW_GROUP** variable command from a bash prompt.

```bash
az group show 2>&1
```

You should back the following response.

```console
az group show: error: the following arguments are required: --name/-n/--resource-group/-g
usage: az group show [-h] [--verbose] [--debug]
                     [--output {json,jsonc,table,tsv,yaml,none}]
                     [--query JMESPATH] [--subscription _SUBSCRIPTION] --name
                     RESOURCE_GROUP_NAME
```

The reason we are getting an error is because we didn't provide the following arguments that are required by the **az group show** command.

```bash
--name
--resource-group
```

In the second part of the script, we are evaluating the contents of the **SHOW_GROUP** variable to see if the word **error** is found in it.

```bash
if [[ $SHOW_GROUP =~ "error" ]]; then
    echo "[---fail------] There was problem running the command."
    echo "[---fail------] $SHOW_GROUP"
    exit 2
fi
```

If **error** is found, then the following error output is returned.

```console
[---fail------] ERROR: az group show: error: the following arguments are required: --name/-n/--resource-group/-g
usage: az group show [-h] [--verbose] [--debug]
                     [--output {json,jsonc,table,tsv,yaml,none}]
                     [--query JMESPATH] [--subscription _SUBSCRIPTION] --name
                     RESOURCE_GROUP_NAME
```

Let's add the script as an inline script into a Build Pipeline in Azure DevOps, it should look similar to what is shown below.

![001](../images/day19/day.19.azure.cli.logging.in.azure.build.pipelines.variable.evaluation.001.png)

<br />

If you run this script above in an Azure Build Pipeline, you should get back the following result.

![002](../images/day19/day.19.azure.cli.logging.in.azure.build.pipelines.variable.evaluation.002.png)

<br />

This works very well and returns everything back as intended. However, there are times where you may want to customize your output for errors so that they easier to read for troubleshooting purposes.

For instance, we could modify the script to only display the first line of the error message held in the **SHOW_GROUP** variable.

```bash
#!/bin/bash
SHOW_GROUP=$(az group show 2>&1)

# Variation 2 - Check the contents of the Variable.
if [[ $SHOW_GROUP =~ "error" ]]; then
    echo "[---fail------] There was problem running the command."
    echo "[---fail------] $SHOW_GROUP\n" | head -n 1
    exit 2
fi
```

If you modify the inline script in your Azure Build Pipeline to match the modified script above, you should get back the following result.

![003](../images/day19/day.19.azure.cli.logging.in.azure.build.pipelines.variable.evaluation.003.png)

<br />

The error message is now on a single line and is easier to find in the rest of the output from the agent job.

When working with variable evaluation in your scripts in an Azure Build Pipeline, you have the ability to control how errors are processed as well as how output from your scripts is displayed in agent jobs. Controlling the output provides you with better readability which can help you to determine where errors are occurring and where to troubleshoot.

<br />

## Conclusion

In today's article we covered evaluating variables in bash script(s) to manipulate the output of your Azure Build Pipelines in Azure CLI tasks. More articles will be coming soon on how to do the same with PowerShell in Azure Build Pipelines.
