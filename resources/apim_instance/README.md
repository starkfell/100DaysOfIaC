# Introduction

This repo hosts the Azure API Management (APIM) instance JSON template, implemented as part of the [100 Days of Infrastructure-as-Code in Azure](https://github.com/starkfell/100DaysOfIaC) initiative.

## Steps in the CI process include

- Trigger build on commit (CI integration)
- Validate ARM template format
- Remove empty resource group
- Create build artifact (ARM template)
- Trigger build pipeline

This artifact is introduced in [Day 12](https://github.com/starkfell/100DaysOfIaC/blob/master/articles/day.12.contin.integration.md) and first deployed in [Day 14](https://github.com/starkfell/100DaysOfIaC/blob/master/articles/day.14.git.started.in.linux.md).