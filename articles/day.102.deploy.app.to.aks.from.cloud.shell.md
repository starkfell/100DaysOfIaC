# Day 102 - Deploying an App to an AKS Cluster from Azure Cloud Shell

In today's article we will be covering how to deploy a simple application to an AKS Cluster from Azure Cloud Shell. We will be working with the Azure Vote Sample Application found in the article, **[Tutorial: Run applications in Azure Kubernetes Service (AKS)](ttps://docs.microsoft.com/en-us/azure/aks/tutorial-kubernetes-deploy-application)**.

In order to make things as easy as possible, all commands in the video are able to be copy and pasted from the **[Video Walkthrough Commands](#video-walkthrough-commands)** section.

</br>

> **NOTE:** All content for this article was tested and written for use with Azure Cloud Shell.

</br>

## Video Walkthrough Commands (aka "the code")

All commands used in video are in the document below.

```bash
# Pulling down a ready-to-go Sample Application from GitHub
wget https://raw.githubusercontent.com/Azure-Samples/azure-voting-app-redis/master/azure-vote-all-in-one-redis.yaml

# Deploying an Application to Kubernetes via URL
kubectl apply -f https://raw.githubusercontent.com/Azure-Samples/azure-voting-app-redis/master/azure-vote-all-in-one-redis.yaml

# Deleting an Application to Kubernetes via URL
kubectl delete -f https://raw.githubusercontent.com/Azure-Samples/azure-voting-app-redis/master/azure-vote-all-in-one-redis.yaml

```

<br/>

## Conclusion

We're REALLY excited to continue this series! If there's a specific scenario that you wish to be covered in future articles, please create a **[New Issue](https://github.com/starkfell/100DaysOfIaC/issues)** in the [starkfell/100DaysOfIaC](https://github.com/starkfell/100DaysOfIaC/) GitHub repository.
