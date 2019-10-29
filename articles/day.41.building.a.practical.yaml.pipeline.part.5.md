# Day 41 - Practical Guide for YAML Build Pipelines in Azure DevOps - Part 5

*The other posts in this Series can be found below.*

***[Day 35 - Practical Guide for YAML Build Pipelines in Azure DevOps - Part 1](./day.35.building.a.practical.yaml.pipeline.part.1.md)***</br>
***[Day 38 - Practical Guide for YAML Build Pipelines in Azure DevOps - Part 2](./day.38.building.a.practical.yaml.pipeline.part.2.md)***</br>
***[Day 39 - Practical Guide for YAML Build Pipelines in Azure DevOps - Part 3](./day.39.building.a.practical.yaml.pipeline.part.3.md)***</br>
***[Day 40 - Practical Guide for YAML Build Pipelines in Azure DevOps - Part 4](./day.40.building.a.practical.yaml.pipeline.part.4.md)***</br>
***[Day 41 - Practical Guide for YAML Build Pipelines in Azure DevOps - Part 5](./day.40.building.a.practical.yaml.pipeline.part.5.md)***</br>

</br>

Today, we are going to further refine the output of the **base-infra.sh** bash script.

While Azure CLI commands are idempotent, there's the possibility that you come across a command that doesn't output content the same way as every other command and you need to understand how you can capture the output of these commands and parse them accordingly.

```text
option 1 - Build GRAV CMS from original Dockerfile
option 2 - cleanup existing scripts for better readability of output in task logs
option 3 - turn everything into scripts that are files and not inline. (conversion option)
```
