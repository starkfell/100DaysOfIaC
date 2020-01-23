# Day 83 - HA for VMs with Availability Zones in ARM

Today, we're going to take a look at another high availability option for Azure VMs - Availability Zones. We'll quickly discuss

## What are Availability Zones?

Availability Zones are unique physical locations within an Azure region. Each zone is made up of one or more datacenters equipped with independent power, cooling, and networking. To ensure resiliency, there’s a minimum of three separate zones in all enabled regions.

## ## How do they work?

An Availability Zone in an Azure region is a combination of a fault domain and an update domain. For example, if you create three or more VMs across three zones in an Azure region, your VMs are effectively distributed across three fault domains and three update domains. The Azure platform recognizes this distribution across update domains to make sure that VMs in different zones

- **Zonal services** – you pin the resource to a specific zone (e.g. VMs, managed disks, Standard IPs, etc.) OR
- **Zone-redundant services** – platform replicates automatically across zones (for example, zone-redundant storage, SQL Database).

## Availability Set vs Availability Zone

A group with two or more VMs in the same datacenter is called an **Availability Set**, which ensures that at least one of the VMs hosted on Azure will be available if something happens. This configuration offers 99.95% SLA. We can configure an availability set ONLY when we deploy a new VM. We can't add an existing VM.

Conveniently, we created an ARM template that deploys three VMs in an availability set in [Day 47](https://github.com/starkfell/100DaysOfIaC/blob/master/articles/day.47.deploy.mult.res.arm.md), so you can find a working example there.

**Availability Zones** are the next level in VM high-availability, because the VMs are in different physical locations within an Azure Region. It can be deployed using one or more Virtual Machines in an Azure Region.  Availability zones offer 99.99% SLA. Availability Zones don't support all VM sizes, but can check what SKUs are supported with a quick PowerShell command:

``` PowerShell
Connect-AzAccount

# Change to the desired target sub
$GetSub = Get-AzSubscription -SubscriptionId <subscription guid>
Select-AzSubscription -SubscriptionObject $GetSub

# Enumerate VM SKUs that support availability zones
Get-AzComputeResourceSku | where {$_.Locations.Contains("eastus") `
                                -and $_.LocationInfo[0].Zones -ne $null `
                                -and $_.ResourceType.Equals("virtualMachines")}
```

The output is shown in Figure 1 below.

![001](../images/day83/001.jpg)

**Figure 1**. Output of PowerShell to enumerate VM SKUs that support availability zones

## EXAMPLE: Adding Availability Zones to VM deployment

Here is the ARM template from day 47, updated to use availability zones instead of availability sets. You'll also find a copy in the [day83](../resources/day83) resources folder.

``` JSON

{
  "$schema": "https://schema.management.azure.com/schemas/2015-01-01/deploymentTemplate.json#",
  "contentVersion": "1.0.0.0",
  "parameters": {
    "virtualMachineAdminUserName": {
      "defaultValue": "pzerger",
      "type": "string",
      "metadata": {
        "description": "Admin username for the local machine"
      }
    },
    "virtualMachineAdminPassword": {
      "type": "securestring",
      "metadata": {
        "description": "Password for the local admin account"
      }
    },
    "envPrefix": {
      "defaultValue": "lab-",
      "type": "string",
      "maxLength": 15,
      "metadata": {
        "description": "Name of the VM to be created"
      }
    },
    "virtualMachineCount": {
      "type": "int",
      "defaultValue": 3,
      "metadata": {
        "description": "Number of VMs to be created"
      }
    },
    "virtualMachineSize": {
      "type": "string",
      "defaultValue": "Standard_D2s_v3",
      "allowedValues": [
        "Standard_D2s_v3",
        "Standard_D4s_v3",
        "Standard_D8s_v3"
      ],
      "metadata": {
        "description": "Virtual Machine Size. The D2s is 2core/8gb, D4 is 4core/16gb, D8 is 8core/32gb"
      }
    },
    "operatingSystem": {
      "type": "string",
      "defaultValue": "Server2016",
      "metadata": {
        "description": "OS on the servers deployed"
      },
      "allowedValues": [
        "Server2012R2",
        "Server2016",
        "Server2019"
      ]
    },
    "dnsPrefixForPublicIP": {
      "type": "string",
      "defaultValue": "[parameters('envPrefix')]",
      "metadata": {
        "description": "Globally unique DNS prefix for the Public IPs assigned to the VMs"
      }
    },
      "NSGName": {
      "type": "string",
      "defaultValue": "FE_NSG",
      "metadata": {
        "description": "This is name of the networkSecurityGroup that will be assigned to FrontEnd Subnet"
      }
    },
    "location": {
      "type": "string",
      "defaultValue": "eastus",
      "metadata": {
        "description": "Location for all resources."
      },
      "allowedValues": [
        "eastus",
        "eastus2",
        "southcentralus",
        "westus"
      ]
    }
  },
   "variables": {
    "myVNETName": "myVNET",
    "myVNETPrefix": "10.0.0.0/16",
    "myVNETSubnet1Name": "Subnet1",
    "myVNETSubnet1Prefix": "10.0.0.0/24",
    "diagnosticStorageAccountName": "[concat('diagst',uniqueString(resourceGroup().id))]",
    "operatingSystemValues": {
      "Server2012R2": {
        "PublisherValue": "MicrosoftWindowsServer",
        "OfferValue": "WindowsServer",
        "SkuValue": "2012-R2-Datacenter"
      },
      "Server2016": {
        "PublisherValue": "MicrosoftWindowsServer",
        "OfferValue": "WindowsServer",
        "SkuValue": "2016-Datacenter"
      }
    },
    "subnetRef": "[resourceId('Microsoft.Network/virtualNetworks/subnets', variables('myVNETName'),  variables('myVNETSubnet1Name'))]"
  },
  "resources": [
       {
      "apiVersion": "2015-05-01-preview",
      "type": "Microsoft.Network/networkSecurityGroups",
      "name": "[parameters('NSGName')]",
      "location": "[parameters('location')]",
      "properties": {
        "securityRules": [
          {
            "name": "rdp_rule",
            "properties": {
              "description": "Allow RDP",
              "protocol": "Tcp",
              "sourcePortRange": "*",
              "destinationPortRange": "3389",
              "sourceAddressPrefix": "Internet",
              "destinationAddressPrefix": "*",
              "access": "Allow",
              "priority": 100,
              "direction": "Inbound"
                }
            }
        ]
    }
},
          {
            "name": "[variables('myVNETName')]",
            "type": "Microsoft.Network/virtualNetworks",
            "location": "[parameters('location')]",
            "apiVersion": "2018-11-01",
            "dependsOn": [
                "[concat('Microsoft.Network/networkSecurityGroups/', parameters('NSGName'))]"
                ],
            "tags": {
            "displayName": "[variables('myVNETName')]"
            },
      "properties": {
        "addressSpace": {
          "addressPrefixes": [
            "[variables('myVNETPrefix')]"
          ]
        },
        "subnets": [
          {
            "name": "[variables('myVNETSubnet1Name')]",
            "properties": {
              "addressPrefix": "[variables('myVNETSubnet1Prefix')]",
              "networkSecurityGroup": {
                "id": "[resourceId('Microsoft.Network/networkSecurityGroups', parameters('NSGName'))]"
              }
            }
          }
        ]
      }
    },
    {
      "name": "[variables('diagnosticStorageAccountName')]",
      "type": "Microsoft.Storage/storageAccounts",
      "location": "[parameters('location')]",
      "apiVersion": "2016-01-01",
      "sku": {
        "name": "Standard_LRS"
      },
      "dependsOn": [],
      "tags": {
        "displayName": "diagnosticStorageAccount"
      },
      "kind": "Storage"
    },
    {
      "type": "Microsoft.Compute/virtualMachines",
      "name": "[concat(parameters('envPrefix'), copyIndex(1))]",
            "zones": [
        "1"
      ],
      "apiVersion": "2017-03-30",
      "location": "[parameters('location')]",
      "copy": {
        "name": "VMcopy",
        "count": "[parameters('virtualMachineCount')]"
      },
      "properties": {
        "hardwareProfile": {
          "vmSize": "[parameters('virtualMachineSize')]"
        },
        "storageProfile": {
          "imageReference": {
            "publisher": "[variables('operatingSystemValues')[parameters('operatingSystem')].PublisherValue]",
            "offer": "[variables('operatingSystemValues')[parameters('operatingSystem')].OfferValue]",
            "sku": "[variables('operatingSystemValues')[parameters('operatingSystem')].SkuValue]",
            "version": "latest"
          },
          "osDisk": {
            "name": "[concat(parameters('envPrefix'),copyIndex(1))]",
            "createOption": "FromImage",
            "managedDisk": {
              "storageAccountType": "Premium_LRS"
            },
            "caching": "ReadWrite"
          }
        },
        "osProfile": {
          "computerName": "[concat(parameters('envPrefix'),copyIndex(1))]",
          "adminUsername": "[parameters('virtualMachineAdminUserName')]",
          "windowsConfiguration": {
            "provisionVMAgent": true
          },
          "secrets": [],
          "adminPassword": "[parameters('virtualMachineAdminPassword')]"
        },
        "networkProfile": {
          "networkInterfaces": [
            {
              "id": "[resourceId('Microsoft.Network/networkInterfaces', concat(parameters('envPrefix'), copyIndex(1), '-NIC1'))]"
            }
          ]
        },
        "diagnosticsProfile": {
          "bootDiagnostics": {
            "enabled": true,
            "storageUri": "[reference(resourceId('Microsoft.Storage/storageAccounts', variables('diagnosticStorageAccountName')), '2016-01-01').primaryEndpoints.blob]"
          }
        }
      },
      "dependsOn": [
        "[concat('Microsoft.Storage/storageAccounts/', variables('diagnosticStorageAccountName'))]",
        "[resourceId('Microsoft.Network/networkInterfaces', concat(parameters('envPrefix'), copyIndex(1), '-NIC1'))]"
      ]
    },
    {
      "type": "Microsoft.Network/networkInterfaces",
      "name": "[concat(parameters('envPrefix'), copyIndex(1), '-NIC1')]",
      "apiVersion": "2016-03-30",
      "location": "[parameters('location')]",
      "copy": {
        "name": "NICCopy",
        "count": "[parameters('virtualMachineCount')]"
      },
      "properties": {
        "ipConfigurations": [
          {
            "name": "ipconfig1",
            "properties": {
              "privateIPAllocationMethod": "Dynamic",
              "publicIPAddress": {
                "id": "[resourceId('Microsoft.Network/publicIPAddresses', concat(parameters('envPrefix'), copyIndex(1), '-PIP1'))]"
              },
              "subnet": {
                "id": "[variables('subnetRef')]"
              }
            }
          }
        ],
        "dnsSettings": {
          "dnsServers": []
        },
        "enableIPForwarding": false
      },
      "dependsOn": [
        "[resourceId('Microsoft.Network/publicIPAddresses', concat(parameters('envPrefix'), copyIndex(1), '-PIP1'))]",
        "[resourceId('Microsoft.Network/virtualNetworks/', variables('myVNETName'))]"
      ]
    },
    {
      "apiVersion": "2016-03-30",
      "type": "Microsoft.Network/publicIPAddresses",
      "name": "[concat(parameters('envPrefix'), copyIndex(1), '-PIP1')]",
      "location": "[parameters('location')]",
      "copy": {
        "name": "PIPCopy",
        "count": "[parameters('virtualMachineCount')]"
      },
      "tags": {
        "displayName": "[concat(parameters('envPrefix'), copyIndex(1), '-PIP1')]"
      },
      "properties": {
        "publicIPAllocationMethod": "Dynamic",
        "dnsSettings": {
          "domainNameLabel": "[concat(parameters('dnsPrefixForPublicIP'), copyIndex(1))]"
        }
      }
    }
  ],
  "outputs": {}
}

```

## Conclusion

Availability zones may not be a feature you will use every day, but definitely worth having another option in your arsenal. Give it a try and ping us back with questions on the 100 Days repo.

Have a topic you'd like us to cover that you haven't seen yet? Open an issue on the 100 Days repo and we'll do our best!