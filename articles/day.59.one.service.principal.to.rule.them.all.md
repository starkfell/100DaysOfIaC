# Day 59 - One Service Principal to Rule Them All

Scenario: You want to manage ALL resources in your Azure Subscription with a single entity that has Owner rights to the Subscription, but can also create additional Service Principals without Company Administrator rights in Azure Active Directory.

Take a look at the diagram below:

![Subscription Management using Service Principals](https://www.plantuml.com/plantuml/png/0/fPDDRnen48Rl_XNEfeTMwh9YkKGSgb1GSqXf4RIzc_LaO-6rtHcRYFpwUZ-Wg2m4gJUMUP_7zenzJrwW3vLcDnAUb04-UGq8Y_WFV_RUqJZBKBmCIkMVmpeGO66D1-C7XQsofIe4IljDWGETDMIwqCBud_ElMIN80sPIaMStoXGwI0Zutre43O8WozDXusxhKrjLrWnSSvAZnGwdkJOM4ovuQEDVWYcyUWimNiJ68ML2wql9cV1Y7RTE-xrGPMcsleJCXH4bLB4nRybNK0HKVjUw7s7tImJjMuBHHXadK5JyioWs9TfWvDHgYws0CQ-y1huAQofGkVh8_E_IF90o9Ly1RbK1V85n0ye9JOo9maT9iX81hKcu8Dx-vBTBa2poaKwgil8fjNJgzdIJdiTIvpre-UsFWB-3LGHx0vRfy8m1o-5rWloi8BzEC3eh65qXQ1hDPx3zxgZ19gypUvnZJM89P0CMy11dvEZzyc7uaIUREqf1Ru6I-F5uHtogG_ssQbtouGoOTw1y4VXqGgvyUPOSTMIS_R_O0gsC7EkcdAQV-aSuZWk0uyDntABJTjUaJcyGwuLhQzETpfAF-KJA0nqVd87cMTOzYx4wttCDZelvfUB9-1ZhkrLrECw3zLsOjfQplhlGraQCtOEHyJc--mC0 "Subscription Management using Service Principals")

We are going to walk through this process, which is similar to what we done before, but we'll be adding only the necessary permissions to the Mgmt Service Principal so that it can deploy additional Service Principals in the future.