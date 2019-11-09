# Day 47 - Deploying resources in Azure with help from ARM Template Functions

When working with Azure Resource Manager (ARM) templates, you want to be familiar with the ARM template functions available to you. This installment will cover these helper functions briefly, including the most common of the lot, and provide a template that demonstrates **copyIndex**, a helper function useful for deploying more than one of a given resource type.

Since ARM is the top of the mountain for idempotent, declarative deployment in Azure, you'll want to explore these functions and what they can do for you.

In this article:

[ARM Template Functions](#arm-template-functions) </br>
[The most common ARM functions](#the-most-common-arm-functions) </br>
[The copyIndex function](#the-copyindex-function) </br>
[Sample ARM deployment scenario](#sample-arm-deployment-scenario) </br>
[Multi-VM sample template](#multi-vm-sample-template) </br>

## ARM Template Functions

There are well over 50 helper functions you can use in your ARM templates, that fall into the following high-level categories.

- **Array and object functions**. functions for working with arrays and objects.
- **Comparison functions**. functions for making comparisons in your templates.
- **Deployment value functions**. functions for getting values from sections of the template and values related to the deployment:

## The most common ARM functions

Most commonly used helper functions are probably these four, all of which are demonstrated in the template accompanying this article

- **resourceId**. returns an object that represents the current resource group.
- **resourceGroup**. returns the unique identifier of a resource. You use this function when the resource name is ambiguous or not provisioned within the same template
- **subscription**. returns details about the subscription for the current deployment.
- **concat**. combines multiple string values and returns the concatenated string, or combines multiple arrays and returns the concatenated array

## The copyIndex function

This template includes a special function I want you to see in action, a numeric function called [**copyIndex**](https://docs.microsoft.com/en-us/azure/azure-resource-manager/resource-group-template-functions-numeric#copyindex). This enables tracking iterative operations to support deployment of multiple resources; multiple VMs and VM components (disks, nics, etc.) in this case.

You can find the details, including examples, of the full list of ARM template functions in [Azure Resource Manager template functions](https://docs.microsoft.com/en-us/azure/azure-resource-manager/resource-group-template-functions)

## Sample ARM deployment scenario

A while ago, I needed to deploy a set of VMs every day. Not a scale set, just standard VMs of the same size. I needed to deploy a half dozen identical VMs in a lab and expose their RDP port for remote access.

## Multi-VM sample template

Here is a multi-VM ARM template you can examine in VSCode. This template defines a few items, including:

- multiple VMs
- VNET and subnet
- Connects VMs to the new subnet
- Public IP address each VM
- Network security group with RDP port 3389 allow rule

You'll find a copy below here and in the [day47](../resources/day47) resources folder
The template uses the **copyIndex** function to enable predictable creation of the number of VMs you specify. It also leverages the **uniqueString** function to generate a string to provide a unique name for the storage account. This function does not guarantee uniqueness, but does a pretty good job when you use against a value like `resourceGroup.id`.

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
      "defaultValue": "Server2019",
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
    "availabilitySetName": "[concat(parameters('envPrefix'), 'availSet')]",
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
    "availabilitySetPlatformFaultDomainCount": "2",
    "availabilitySetPlatformUpdateDomainCount": "5",
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
      "type": "Microsoft.Compute/availabilitySets",
      "name": "[variables('availabilitySetName')]",
      "apiVersion": "2017-03-30",
      "location": "[parameters('location')]",
      "properties": {
        "platformFaultDomainCount": "[variables('availabilitySetPlatformFaultDomainCount')]",
        "platformUpdateDomainCount": "[variables('availabilitySetPlatformUpdateDomainCount')]"
      },
      "sku": {
        "name": "Aligned"
      }
    },
    {
      "type": "Microsoft.Compute/virtualMachines",
      "name": "[concat(parameters('envPrefix'), copyIndex(1))]",
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
        "availabilitySet": {
          "id": "[resourceId('Microsoft.Compute/availabilitySets', variables('availabilitySetName'))]"
        },
        "diagnosticsProfile": {
          "bootDiagnostics": {
            "enabled": true,
            "storageUri": "[reference(resourceId('Microsoft.Storage/storageAccounts', variables('diagnosticStorageAccountName')), '2016-01-01').primaryEndpoints.blob]"
          }
        }
      },
      "dependsOn": [
        "[concat('Microsoft.Compute/availabilitySets/', variables('availabilitySetName'))]",
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