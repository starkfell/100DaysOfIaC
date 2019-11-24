# Day 59 - Practical Guide for YAML Build Pipelines in Azure DevOps - Part 10

*The other posts in this Series can be found below.*

***[Day 35 - Practical Guide for YAML Build Pipelines in Azure DevOps - Part 1](./day.35.building.a.practical.yaml.pipeline.part.1.md)***</br>
***[Day 38 - Practical Guide for YAML Build Pipelines in Azure DevOps - Part 2](./day.38.building.a.practical.yaml.pipeline.part.2.md)***</br>
***[Day 39 - Practical Guide for YAML Build Pipelines in Azure DevOps - Part 3](./day.39.building.a.practical.yaml.pipeline.part.3.md)***</br>
***[Day 40 - Practical Guide for YAML Build Pipelines in Azure DevOps - Part 4](./day.40.building.a.practical.yaml.pipeline.part.4.md)***</br>
***[Day 41 - Practical Guide for YAML Build Pipelines in Azure DevOps - Part 5](./day.41.building.a.practical.yaml.pipeline.part.5.md)***</br>
***[Day 49 - Practical Guide for YAML Build Pipelines in Azure DevOps - Part 6](./day.49.building.a.practical.yaml.pipeline.part.6.md)***</br>
***[Day 50 - Practical Guide for YAML Build Pipelines in Azure DevOps - Part 7](./day.50.building.a.practical.yaml.pipeline.part.7.md)***</br>
***[Day 51 - Practical Guide for YAML Build Pipelines in Azure DevOps - Part 8](./day.51.building.a.practical.yaml.pipeline.part.8.md)***</br>
***[Day 58 - Practical Guide for YAML Build Pipelines in Azure DevOps - Part 9](./day.58.building.a.practical.yaml.pipeline.part.9.md)***</br>
***[Day 59 - Practical Guide for YAML Build Pipelines in Azure DevOps - Part 10](./day.59.building.a.practical.yaml.pipeline.part.10.md)***</br>

</br>

Today, we are going to continue where we left off in **[Part 9](./day.58.building.a.practical.yaml.pipeline.part.9.md)** we are going to discuss configuration and access of the NGINX Docker Container and its associated Image.

> **NOTE:** Replace all instances of **pracazconreg** in this article with the name you provided for the Azure Container Registry in **[Part 2](./day.38.building.a.practical.yaml.pipeline.part.2.md)**!

</br>

**In this article:**

[Update the permissions of the Service Principal used for the Build Pipeline](#update-the-permissions-of-the-service-principal-used-for-the-build-pipeline)</br>
[Add in a new Bash Script for Deploying an Azure Container Instance](#add-in-a-new-bash-script-for-deploying-an-azure-container-instance)</br>
[deploy-nginx-aci.sh Script Breakdown](#deploy-nginx-acish-script-breakdown)</br>
[Update the YAML File for the Build Pipeline](#update-the-yaml-file-for-the-build-pipeline)</br>
[Check on the Build Pipeline Job](#check-on-the-build-pipeline-job)</br>
[Things to Consider](#things-to-consider)</br>
[Conclusion](#conclusion)</br>

## Why isn't the NGINX Application accessible

Setup a default configuration of NGINX to run on port 443 and port 80.

