<# 
 .SYNOPSIS
  Test Azure Resource Manager (ARM) template using Pester. The following tests are performed:
    * Template file validation
      * Test if the ARM template file exists
      * Test if the ARM template is a valid JSON file
    * Template content validation
      * Contains all required elements
      * Only contains valid elements
      * Has valid Content Version
      * Only has approved parameters
      * Only has approved variables
      * Only has approved functions
      * Only has approved resources
      * Only has approved outputs

 .DESCRIPTION

 .PARAMETER -TemplatePath
  The path to the ARM Template that needs to be tested against.

 .PARAMETER -parameters
  The names of all parameters the ARM template should contain (optional).

 .PARAMETER -variables
  The names of all variables the ARM template should contain (optional).

 .PARAMETER -functions
  The list of all the functions (namespace.member) the ARM template should contain (optional).

 .PARAMETER -resources
  The list of resources (of its type) the ARM template should contain. Only top level resources are supported. child resources defined in the templates are not supported.

 .PARAMETER -output
  The names of all outputs the ARM template should contain (optional).

 .EXAMPLE
  # Test ARM template file with parameters, variables, functions, resources and outputs:
   $params = @{
    TemplatePath = 'c:\temp\azuredeploy.json'
    parameters = 'virtualMachineNamePrefix', 'virtualMachineSize', 'adminUsername', 'virtualNetworkResourceGroup', 'virtualNetworkName', 'adminPassword', 'subnetName'
    variables = 'nicName', 'publicIpAddressName', 'publicIpAddressSku', 'publicIpAddressType', 'subnetRef', 'virtualMachineName', 'vnetId'
    functions = 'tyang.uniqueName'
    resources = 'Microsoft.Compute/virtualMachines', 'Microsoft.Network/networkInterfaces', 'Microsoft.Network/publicIpAddresses'
    outputs = 'adminUsername'
  }
  .\Test.ARMTemplate.ps1 @params
  
 .EXAMPLE
   # Test ARM template file with only the resources elements:
    $params = @{
    TemplatePath = 'c:\temp\azuredeploy.json'
    resources = 'Microsoft.Compute/virtualMachines', 'Microsoft.Network/networkInterfaces', 'Microsoft.Network/publicIpAddresses'
  }
  .\Test.ARMTemplate.ps1 @params
#>
<#
======================================
AUTHOR:  Tao Yang 
DATE:    09/09/2018
Version: 1.0
Comment: Pester Test for ARM Template
======================================
#>
[CmdLetBinding()]
param (
	[Parameter(Mandatory=$true)]
	[string]$TemplatePath,

	[Parameter(Mandatory=$false)]
	[string[]]$parameters,
	
	[Parameter(Mandatory=$false)]
	[string[]]$variables,
	
	[Parameter(Mandatory=$false)]
	[string[]]$functions,

	[Parameter(Mandatory=$true)]
	[string[]]$resources,

	[Parameter(Mandatory=$false)]
	[string[]]$outputs
)

#variables
$requiredElements = New-object System.Collections.ArrayList
$optionalElements = New-Object System.Collections.ArrayList
[void]$requiredElements.Add('$schema')
[void]$requiredElements.Add('contentversion')
[void]$requiredElements.Add('resources')

[void]$optionalElements.Add('parameters')
[void]$optionalElements.Add('variables')
[void]$optionalElements.Add('functions')
[void]$optionalElements.Add('outputs')

#Read template file
$TemplateContent = Get-Content $TemplatePath -Raw -ErrorAction SilentlyContinue
$TemplateJson = ConvertFrom-Json -InputObject $TemplateContent -ErrorAction SilentlyContinue
If ($TemplateJson)
{
  $TemplateElements = $TemplateJson.psobject.Properties.name.tolower()
} else {
  $TemplateElements = $null
}

#determine what tests to perform
If ($PSBoundParameters.ContainsKey('parameters'))
{
  $bCheckParameters = $true
}

If ($PSBoundParameters.ContainsKey('variables'))
{
  $bCheckVariables = $true
}

If ($PSBoundParameters.ContainsKey('functions'))
{
  $bCheckFunctions = $true
}

If ($PSBoundParameters.ContainsKey('outputs'))
{
  $bCheckOutputs = $true
}

#Pester tests
Describe 'ARM Template Validation' {
	Context 'Template File Validation' {
		It 'Template File Exists' {
			Test-Path $TemplatePath -PathType Leaf -Include '*.json' | Should Be $true
		}

		It 'ARM Template is a valid JSON file' {
			$TemplateContent | ConvertFrom-Json -ErrorAction SilentlyContinue | Should Not Be $Null
	  }
  }

  Context 'Template Content Validation' {
      It "Contains all required elements" {
      $bValidRequiredElements = $true
      Foreach ($item in $requiredElements)
      {
        if (-not $TemplateElements.Contains($item))
        {
          $bValidRequiredElements = $false
          Write-Output "template does not contain '$item'"
        }
      }
      $bValidRequiredElements | Should be $true
    }

    It "Only contains valid elements" {
      $bValidElements = $true
      Foreach ($item in $TemplateElements)
      {
        if ((-not $requiredElements.Contains($item)) -and (-not $optionalElements.Contains($item)))
        {
          $bValidElements = $false
        }
      }
      $bValidElements | Should be $true
    }

    It "Has valid Content Version" {
      If ($TemplateJson.contentVersion -match '^[0-9]+.[0-9]+.[0-9]+.[0-9]+$')
      {
        $bValidContentVersion = $true
      } else {
        $bValidContentVersion = $false
      }
      $bValidContentVersion | Should be $true
    }
    
    If ($bCheckParameters -eq $true)
    {
      It "Only has approved parameters" {
        $parametersFromTemplateFile = $TemplateJson.parameters.psobject.Properties.name | Sort-Object
        $strParametersFromTemplateFile = $parametersFromTemplateFile -join ','
        $parameters = $parameters | Sort-Object
        $strParameters = $parameters -join ','
        $strParametersFromTemplateFile | Should be $strParameters
      }
    }

    if ($bCheckVariables)
    {
      It "Only has approved variables" {
        $variablesFromTemplateFile = $TemplateJson.variables.psobject.Properties.name | Sort-Object
        $variables = $variables | Sort-Object
        $strVariablesFromTemplate = $variablesFromTemplateFile -join ','
        $strVariables = $variables -join ','
        $strVariablesFromTemplate | Should be $strVariables
      }
    }
    
    if ($bCheckFunctions)
    {
      It "Only has approved functions" {
        #parse functions from the template file
        $arrFunctionsFromTemplateFile = @()
        Foreach ($item in $TemplateJson.functions)
        {
          foreach ($member in $item.members.psobject.Properties.name)
          {
            $arrFunctionsFromTemplateFile += "$($item.namespace).$member"
          }
        }
        $arrFunctionsFromTemplateFile = $arrFunctionsFromTemplateFile | Sort-Object
        $strFunctionsFromTemplateFile = $arrFunctionsFromTemplateFile -join ','

        #parse input parameter functions
        $arrApprovedFunctions = $functions | Sort-Object
        $strApprovedFunctions = $arrApprovedFunctions -join ","
        $strFunctionsFromTemplateFile | Should be $strApprovedFunctions
      }
    }

    It "Only has approved resources" {
      $resourcesFromTemplate = $TemplateJson.resources.type | Sort-Object
      $strResourcesFromTemplate = $resourcesFromTemplate -join ','
      $resources = $resources | Sort-Object
      $strResources = $resources -join ','
      $strResourcesFromTemplate | Should be $strResources
    }

    If ($bCheckOutputs)
    {
      It "Only has approved outputs" {
      $outputsFromTemplate = $TemplateJson.outputs.psobject.Properties.name | Sort-Object
      $strOutputsFromTemplate = $outputsFromTemplate -join ','
      $outputs = $outputs | Sort-Object
      $strOutputs = $outputs -join ','
      $strOutputsFromTemplate | Should be $strOutputs
    }
    }
  }
}

#Done