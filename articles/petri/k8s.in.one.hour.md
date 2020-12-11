
# KUBERNETES: UP AND RUNNING IN AN HOUR

These are the steps for deploying the Azure Kubernetes Service resources as shown in "Kubernetes: Up and running in an hour"

## STEP 1: CLONE THE GIT REPOSITORY FROM GITHUB

To clone the Github repo shown in the demonstration (https://github.com/starkfell/100DaysOfIaC), you can run this command to clone with the Github command line.

```bash
gh repo clone starkfell/100DaysOfIaC
```

## STEP 2: CREATE A RESOURCE GROUP IN AZURE

If you have multiple Azure subscriptions, in the Azure CLI in Azure Cloud Shell, you can list subscriptions you have access to.

```bash
az account list
```
And then set your preferred subscription:

```bash
az account set --subscription 'Windows Azure MSDN - Visual Studio Ultimate'
```

And then, create your resource group using this command:

```bash
az group create --name myk8srg --location eastus
```

NOTE: Running on a local computer and don't have Azure CLI installed? Get step-by-step instructions [HERE](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli).

## STEP 3: CREATE AN AKS CLUSTER

With this command, you can deploy your AKS Cluster, as well as automatically enable Azure Monitor for Containers to monitor the cluster:

```bash
az aks create --resource-group myk8srg --name myAKSCluster --node-count 1 --enable-addons monitoring --generate-ssh-keys
```

## STEP 4: CONNECT TO THE AKS CLUSTER

This command downloads credentials and configures the Kubernetes CLI to use them.

```bash
az aks get-credentials --resource-group myk8srg --name myAKSCluster
```

Use kubectl to manage your cluster. It's pre-installed in Azure Cloud Shell. If you are running Azure CLI on your local computer, you can install it with this command:

```bash
az aks install-cli
```

Verify connection by pulling list of nodes

```bash
kubectl get nodes
```

## STEP 5: RUN THE APPLICATION

The contents of the Azure Voting App yaml definition file are shown here. You can copy-and-paste if you don't want to sync the Github repo from Step 1.

```YAML
apiVersion: apps/v1
kind: Deployment
metadata:
  name: azure-vote-back
spec:
  replicas: 1
  selector:
    matchLabels:
      app: azure-vote-back
  template:
    metadata:
      labels:
        app: azure-vote-back
    spec:
      nodeSelector:
        "beta.kubernetes.io/os": linux
      containers:
      - name: azure-vote-back
        image: mcr.microsoft.com/oss/bitnami/redis:6.0.8
        env:
        - name: ALLOW_EMPTY_PASSWORD
          value: "yes"
        resources:
          requests:
            cpu: 100m
            memory: 128Mi
          limits:
            cpu: 250m
            memory: 256Mi
        ports:
        - containerPort: 6379
          name: redis
---
apiVersion: v1
kind: Service
metadata:
  name: azure-vote-back
spec:
  ports:
  - port: 6379
  selector:
    app: azure-vote-back
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: azure-vote-front
spec:
  replicas: 1
  selector:
    matchLabels:
      app: azure-vote-front
  template:
    metadata:
      labels:
        app: azure-vote-front
    spec:
      nodeSelector:
        "beta.kubernetes.io/os": linux
      containers:
      - name: azure-vote-front
        image: mcr.microsoft.com/azuredocs/azure-vote-front:v1
        resources:
          requests:
            cpu: 100m
            memory: 128Mi
          limits:
            cpu: 250m
            memory: 256Mi
        ports:
        - containerPort: 80
        env:
        - name: REDIS
          value: "azure-vote-back"
---
apiVersion: v1
kind: Service
metadata:
  name: azure-vote-front
spec:
  type: LoadBalancer
  ports:
  - port: 80
  selector:
    app: azure-vote-front
```

Now, run the app using this command

```bash
kubectl apply -f votingapp.yml
```

## STEP 6: TEST THE APPLICATION

```bash
kubectl get service azure-vote-front
```

To see the Azure Vote app in action, open a web browser and type or paste the external IP address of your service.

To clean up after testing, delete the cluster using this command:

```bash
az group delete --name myk8srg --yes --no-wait
```

# ADDITIONAL READING

Tutorial: Deploy and use Azure Container Registry
https://docs.microsoft.com/en-us/azure/aks/tutorial-kubernetes-prepare-acr

Tutorial: Scale applications in Azure Kubernetes Service (AKS)
https://docs.microsoft.com/en-us/azure/aks/tutorial-kubernetes-scale

Tutorial: Update an application in Azure Kubernetes Service (AKS)
https://docs.microsoft.com/en-us/azure/aks/tutorial-kubernetes-app-update

Tutorial: Upgrade Kubernetes in Azure Kubernetes Service (AKS)
https://docs.microsoft.com/en-us/azure/aks/tutorial-kubernetes-upgrade-cluster
