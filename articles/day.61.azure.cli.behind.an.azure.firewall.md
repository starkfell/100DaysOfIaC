# Day 61 - Using the Azure CLI behind an Azure Firewall

Today's post will be terse and to the point as I have glorious hoppy fermented beverages awaiting me in downtown Graz and you, dear reader, should be enjoying some sort of Thanksgiving meal with your family!

</br>

Recently I can across the following error message when attempting to login to Azure using the Azure CLI behind an Azure Firewall.

```log
request failed: Certificate verification failed. This typically happens when using Azure CLI behind a proxy
that intercepts traffic with a self-signed certificate. Please add this certificate to the trusted CA bundle:
https://github.com/Azure/azure-cli/blob/dev/doc/use_cli_effectively.md#working-behind-a-proxy.
Error detail: Error occurred in request., SSLError: HTTPSConnectionPool(host='management.azure.com', port=443):
Max retries exceeded with url: /subscriptions?api-version=2016-06-01
(Caused by SSLError(SSLError("bad handshake: SysCallError(-1, 'Unexpected EOF')",),))
```

</br>

After some quick Googling, I came across an outstanding blog post from 2017 written by Stefan Johner on **[using the Azure CLI behind a corporate proxy server](https://blog.jhnr.ch/2017/09/24/use-azure-cli-with-corporate-proxy-server/).** Per Stefan's Blog post and Microsoft's Official documentation on **[using Azure CLI behind a proxy](https://github.com/Azure/azure-cli/blob/dev/doc/use_cli_effectively.md#working-behind-a-proxy)**, you have two options that usually work:

* **OPTION 1:** Append your proxy server's certificate to the location of your CA bundle certificate file on your host and then set the environment variable, REQUESTS_CA_BUNDLE, to point to it.
* **OPTION 2:** Disable certificate checks by setting the environment variable: AZURE_CLI_DISABLE_CONNECTION_VERIFICATION=1

</br>

Unfortunately, neither of these options was resolving my issue. So I turned on debugging when running **az login** and when attempting to login I was returned the following errors right before the Error shown above.

```log
msrest.universal_http.requests : Configuring retry: max_retries=4, backoff_factor=0.8, max_backoff=90
msrest.async_paging : Paging async iterator protocol is not available for SubscriptionPaged
msrest.universal_http : Configuring redirects: allow=True, max=30
msrest.universal_http : Configuring request: timeout=100, verify=True, cert=None
msrest.universal_http : Configuring proxies: ''
msrest.universal_http : Evaluate proxies against ENV settings: True
urllib3.connectionpool : Starting new HTTPS connection (1): management.azure.com:443
urllib3.util.retry : Incremented Retry for (url='/subscriptions?api-version=2016-06-01'): Retry(total=3, connect=4, read=4, redirect=None, status=None)
urllib3.connectionpool : Retrying (Retry(total=3, connect=4, read=4, redirect=None, status=None)) after connection broken by 'SSLError(SSLError("bad handshake: SysCallError(-1, 'Unexpected EOF')",),)': /subscriptions?api-version=2016-06-01
urllib3.connectionpool : Starting new HTTPS connection (2): management.azure.com:443
urllib3.util.retry : Incremented Retry for (url='/subscriptions?api-version=2016-06-01'): Retry(total=2, connect=4, read=4, redirect=None, status=None)
urllib3.connectionpool : Retrying (Retry(total=2, connect=4, read=4, redirect=None, status=None)) after connection broken by 'SSLError(SSLError("bad handshake: SysCallError(-1, 'Unexpected EOF')",),)': /subscriptions?api-version=2016-06-01
urllib3.connectionpool : Starting new HTTPS connection (3): management.azure.com:443
urllib3.util.retry : Incremented Retry for (url='/subscriptions?api-version=2016-06-01'): Retry(total=1, connect=4, read=4, redirect=None, status=None)
urllib3.connectionpool : Retrying (Retry(total=1, connect=4, read=4, redirect=None, status=None)) after connection broken by 'SSLError(SSLError("bad handshake: SysCallError(-1, 'Unexpected EOF')",),)': /subscriptions?api-version=2016-06-01
urllib3.connectionpool : Starting new HTTPS connection (4): management.azure.com:443
urllib3.util.retry : Incremented Retry for (url='/subscriptions?api-version=2016-06-01'): Retry(total=0, connect=4, read=4, redirect=None, status=None)
urllib3.connectionpool : Retrying (Retry(total=0, connect=4, read=4, redirect=None, status=None)) after connection broken by 'SSLError(SSLError("bad handshake: SysCallError(-1, 'Unexpected EOF')",),)': /subscriptions?api-version=2016-06-01
```

</br>

I wasn't getting very far with this information, so I decided to log in using **az login** from a machine outside of the Azure Firewall with debugging turned on that I knew could login to Azure without any issues. The section below is what happens right before it does it's SSL Checks and attempts to connect to **management.azure.com**.

```log
msrest.universal_http.requests : Configuring retry: max_retries=4, backoff_factor=0.8, max_backoff=90
msrest.async_paging : Paging async iterator protocol is not available for SubscriptionPaged
msrest.universal_http : Configuring redirects: allow=True, max=30
msrest.universal_http : Configuring request: timeout=100, verify=True, cert=None
msrest.universal_http : Configuring proxies: ''
msrest.universal_http : Evaluate proxies against ENV settings: True
urllib3.connectionpool : Starting new HTTPS connection (1): management.azure.com:443
urllib3.connectionpool : https://management.azure.com:443 "GET /subscriptions?api-version=2016-06-01 HTTP/1.1" 200 348
```

</br>

In particular what was telling is the line below.

```log
urllib3.connectionpool : https://management.azure.com:443 "GET /subscriptions?api-version=2016-06-01 HTTP/1.1" 200 348
```

After talking with the network Guru's that manage the Azure Firewall, we enabled access to **management.azure.com** on ports 443 and 80 and the login finally succeeded.

***
SPONSOR: Need to stop and start your development VMs on a schedule? The Azure Resource Scheduler let's you schedule up to 10 Azure VMs for FREE! Learn more [HERE](https://azuremarketplace.microsoft.com/en-us/marketplace/apps/lumagatena.resourcescheduler?tab=Overview)
***

## Conclusion

In today's article we discussed an issue about using the Azure CLI to login to Azure while working behind an Azure Firewall. If there's a specific scenario that you wish to be covered in future articles, please create a **[New Issue](https://github.com/starkfell/100DaysOfIaC/issues)** in the [starkfell/100DaysOfIaC](https://github.com/starkfell/100DaysOfIaC/) GitHub repository.
