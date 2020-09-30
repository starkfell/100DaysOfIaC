# Day 102 - Deploying an App to an AKS Cluster from Azure Cloud Shell

**IN-PROGRESS...**

In today's article we will be covering how to deploy a simple application to an AKS Cluster from Azure Cloud Shell. We will be working with the Azure Vote Sample Application found in the article, **[Tutorial: Run applications in Azure Kubernetes Service (AKS)](ttps://docs.microsoft.com/en-us/azure/aks/tutorial-kubernetes-deploy-application)**. We deployed an AKS cluster from the Azure Cloud Shell in [Day 101](https://github.com/starkfell/100DaysOfIaC/blob/master/articles/day.101deploy.aks.from.cloud.shell.afap.md). So, if you don't have an AKS cluster on hand, visit [Day 101](https://github.com/starkfell/100DaysOfIaC/blob/master/articles/day.101deploy.aks.from.cloud.shell.afap.md) and deploy one! 

In order to make things as easy as possible, all commands in the video are able to be copy and pasted from the **[Video Walkthrough Commands](#video-walkthrough-commands)** section.

Find the code and reference links below!

</br>

## Video Walkthrough (YouTube)

**TO VIEW:** Click **[HERE](https://www.youtube.com/channel/UCAr0yk0um7lwLjmrKfzwyig)** to view the walkthrough video on Youtube at https://youtu.be/T3GQ4FyTu-Y!

**TO SUBSCRIBE:** Click **[HERE](https://www.youtube.com/channel/UCAr0yk0um7lwLjmrKfzwyig?sub_confirmation=1)** to follow us on Youtube so you get a heads up on future videos!

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

</br>

## Conclusion

We're REALLY excited to continue this series! If there's a specific scenario that you wish to be covered in future articles, please create a **[New Issue](https://github.com/starkfell/100DaysOfIaC/issues)** in the [starkfell/100DaysOfIaC](https://github.com/starkfell/100DaysOfIaC/) GitHub repository.
