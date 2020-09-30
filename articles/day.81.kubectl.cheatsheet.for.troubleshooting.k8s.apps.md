# Day 81 - Troubleshooting Your Applications in Kubernetes using kubectl

While there are many guides and cheat sheets for using **kubectl** already available online, I wanted to provide the most common **kubectl** commands that I use on a regular basis to troubleshoot applications running in a Kubernetes Environment.

</br>

In today's article we will cover the following scenarios when troubleshooting your Kubernetes Applications using **kubectl**.

[Checking the Events on a Pod](#checking-the-events-on-a-pod)</br>
[Checking the Logs on a Pod](#checking-the-logs-on-a-pod)</br>
[Retrieving the IP Address of a Pod](#retrieving-the-ip-address-of-a-pod)</br>
[Connecting to a Pod](#connecting-to-a-pod)</br>
[Things to Consider](#things-to-consider)</br>
[Conclusion](#conclusion)</br>

***
SPONSOR: Need to stop and start your development VMs on a schedule? The Azure Resource Scheduler let's you schedule up to 10 Azure VMs for FREE! Learn more [HERE](https://azuremarketplace.microsoft.com/en-us/marketplace/apps/lumagatena.resourcescheduler?tab=Overview)
***

## Checking the Events on a Pod

One of the most common issues I see on new Applications that are containerized is their inability to startup when running in a Kubernetes Cluster. The first thing I do is pull up the Events of the Pod.

```bash
kubectl describe troubleshooting-deployment-66cb5b7547-b9wgk
```

At the bottom of the output, you will see the latest events of the Pod being scheduled to a Node, pulling it's container image, and starting up.

```console
Events:
  Type    Reason     Age   From                                Message
  ----    ------     ----  ----                                -------
  Normal  Scheduled  12m   default-scheduler                   Successfully assigned default/troubleshooting-deployment-7f5c7fb775-6xmjz to k8s-linuxpool1-11223344-0
  Normal  Pulling    11m   kubelet, k8s-linuxpool1-11223344-0  Pulling image "starkfell/k8s-jumpbox"
  Normal  Pulled     11m   kubelet, k8s-linuxpool1-11223344-0  Successfully pulled image "starkfell/k8s-jumpbox"
  Normal  Created    11m   kubelet, k8s-linuxpool1-11223344-0  Created container troubleshooting
  Normal  Started    11m   kubelet, k8s-linuxpool1-11223344-0  Started container troubleshooting
```

</br>

You can also run the following command below to retrieve the latest events for all resources in the cluster.

```bash
kubectl get events
```

Your output should look similar to what is shown below.

```console
LAST SEEN   TYPE     REASON              OBJECT                                             MESSAGE
15m         Normal   Scheduled           pod/troubleshooting-deployment-7f5c7fb775-6xmjz    Successfully assigned default/troubleshooting-deployment-7f5c7fb775-6xmjz to k8s-linuxpool1-11223344-0
15m         Normal   Pulling             pod/troubleshooting-deployment-7f5c7fb775-6xmjz    Pulling image "starkfell/k8s-jumpbox"
15m         Normal   Pulled              pod/troubleshooting-deployment-7f5c7fb775-6xmjz    Successfully pulled image "starkfell/k8s-jumpbox"
15m         Normal   Created             pod/troubleshooting-deployment-7f5c7fb775-6xmjz    Created container troubleshooting
15m         Normal   Started             pod/troubleshooting-deployment-7f5c7fb775-6xmjz    Started container troubleshooting
16m         Normal   Killing             pod/troubleshooting-deployment-7f5c7fb775-ng6zg    Stopping container troubleshooting
15m         Normal   SuccessfulCreate    replicaset/troubleshooting-deployment-7f5c7fb775   Created pod: troubleshooting-deployment-7f5c7fb775-6xmjz
15m         Normal   ScalingReplicaSet   deployment/troubleshooting-deployment              Scaled up replica set troubleshooting-deployment-7f5c7fb775 to 1
```

</br>

## Checking the Logs on a Pod

When troubleshooting Applications running in Kubernetes, I often have at least two SSH Sessions open, one for watching log output from a Pod and one for running queries against the Pod.

Pull up the existing Pods in your K8s Cluster running under namespace **kube-system**

```bash
kubectl get po -n kube-system
```

You should get back something similar.

```console
NAME                                            READY   STATUS    RESTARTS   AGE
azure-cni-networkmonitor-v655g                  1/1     Running   0          37d
azure-ip-masq-agent-4c8s4                       1/1     Running   0          37d
blobfuse-flexvol-installer-b774h                1/1     Running   0          37d
coredns-7f8646d79b-wxvtz                        1/1     Running   0          37d
keyvault-flexvolume-2n7fj                       1/1     Running   0          37d
keyvault-flexvolume-4gvsh                       1/1     Running   0          37d
kube-addon-manager-k8s-master-11223344-0        1/1     Running   0          37d
kube-apiserver-k8s-master-11223344-0            1/1     Running   0          37d
kube-controller-manager-k8s-master-11223344-0   1/1     Running   0          37d
kube-proxy-7wct2                                1/1     Running   0          37d
kube-proxy-ctl8h                                1/1     Running   0          37d
kube-scheduler-k8s-master-11223344-0            1/1     Running   0          37d
kubernetes-dashboard-66dd8b8df7-9pqnj           1/1     Running   0          37d
metrics-server-864ffbc5c-5xhft                  1/1     Running   0          37d
```

Run the following command to retrieve the current logs of **kube-apiserver-k8s-master-11223344-0**.

```bash
kubectl logs kube-apiserver-k8s-master-11223344-0 -n kube-system
```

You screen will be inundated without for a few seconds but will eventually finish.

In order to reduce the amount of output to something more manageable, run the following command to output the last 10 lines from the logs.

```bash
kubectl logs kube-apiserver-k8s-master-11223344-0 --tail=10 -n kube-system
```

The output you get back should be much more readable.

Finally, we can modify the command again in order to continuously watch the logs of the Pod, but only starting from the last 10 lines of log output by running the following command.

```bash
kubectl logs kube-apiserver-k8s-master-11223344-0 --tail=10 -n kube-system -f
```

The output of the logs will run as a continuous stream to your screen until you hit **CTRL + C**.

</br>

## Retrieving the IP Address of a Pod

To quickly pull up the IP Address of a Pod, run the following command

```bash
kubectl get po troubleshooting-deployment-66cb5b7547-b9wgk -o wide
```

You should get back similar output.

```console
NAME                                          READY   STATUS    RESTARTS   AGE   IP             NODE                        NOMINATED NODE   READINESS GATES
troubleshooting-deployment-7f5c7fb775-6xmjz   1/1     Running   0          25m   10.167.42.16   k8s-linuxpool1-15336332-0   <none>           <none>
```

</br>

If you are troubleshooting network connectivity issues with a Kubernetes Cluster running in a custom VNet, having a quick way to pull up the IP Addresses of all Pods running in the cluster can be quite useful.

Use the following command to list the IP Addresses of each Pod on the Kubernetes Cluster in every namespace.

```bash
kubectl get pods --all-namespaces -o wide
```

</br>

## Connecting to a Pod

At some point you are going to have to connect directly to a Pod to troubleshoot it. Run the following command to connect to a Pod and pull up a bash prompt.

```bash
kubectl exec -ti troubleshooting-deployment-7f5c7fb775-6xmjz -- /bin/bash
```

> NOTE: It's entirely possible that **bash** won't be available on the Pod so you'll have to use **/bin/sh** instead.

In order to disconnect from the Pod, type **exit**

</br>

## Things to Consider

Below are some additional links that you may find useful when using **kubectl**.

[kubectl Cheat Sheet](https://kubernetes.io/docs/reference/kubectl/cheatsheet/)</br>
[Kubectl cheatsheet (Unofficial)](https://unofficial-kubernetes.readthedocs.io/en/latest/user-guide/kubectl-cheatsheet/)</br>
[cheatsheet-kubernetes-A4](https://github.com/dennyzhang/cheatsheet-kubernetes-A4)</br>

## Conclusion

In today's article we we covered several scenarios for using **kubectl** to assist in troubleshooting your Kubernetes Applications. If there's a specific scenario that you wish to be covered in future articles, please create a **[New Issue](https://github.com/starkfell/100DaysOfIaC/issues)** in the [starkfell/100DaysOfIaC](https://github.com/starkfell/100DaysOfIaC/) GitHub repository.
