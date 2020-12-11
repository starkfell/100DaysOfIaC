
# KUBERNETES: UP AND RUNNING IN AN HOUR

## STEP 1: PULL THE CODE FROM THE GIT REPO

List subscriptions you have access to.

```bash
az account list
```

Set your preferred subscription:

```bash
az account set --subscription 'Windows Azure MSDN - Visual Studio Ultimate'
```

Azure Cloud Shell - Bash
https://docs.microsoft.com/en-us/azure/cloud-shell/quickstart

Azure Cloud Shell - PowerShell
https://docs.microsoft.com/en-us/azure/cloud-shell/quickstart-powershell

## STEP 2: CREATE A RESOURCE GROUP IN AZURE

```bash
az group create --name myk8srg --location eastus
```


NOTE: Don't have Azure CLI installed? Get step-by-step instructions [HERE](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli).

## DISCUSSION: DO I NEED A PRIVATE AKS CLUSTER?

## STEP 3: CREATE AN AKS CLUSTER 

```bash
az aks create --resource-group myk8srg --name myAKSCluster --node-count 1 --enable-addons monitoring --generate-ssh-keys
```
IMPORTANT: Backup


## STEP 4: CONNECT TO THE AKS CLUSTER

Use kubectl to manage your cluster. It's pre-installed in Azure Cloud Shell.
az aks install-cli

# This command downloads credentials and configures the Kubernetes CLI to use them.
az aks get-credentials --resource-group myk8srg --name myAKSCluster

Verify connection by pulling list of nodes

```bash
kubectl get nodes
```

## STEP 5: RUN THE APPLICATION

kubectl apply -f votingapp.yml

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

## STEP 6: TEST THE APPLICATION

```bash
kubectl get service azure-vote-front --watch
```

To see the Azure Vote app in action, open a web browser to the external IP address of your service.

Cleanup - delete the cluster

```bash
az group delete --name myResourceGroup --yes --no-wait
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



