/*

Template: resourceGroup.bicep

*/

// Standard Parameters.
param rgName string
param azLoc string

// Tag Parameters.
param rgTagName string
param rgTagEnvName string
param rgTagDeployedBy string

// Resource Group Template.
resource resourcGroup 'Microsoft.Resources/resourceGroups@2020-06-01' = {
  name: rgName
  location: azLoc
  tags:{
    Name: rgTagName
    Environment: rgTagEnvName
    DeployedBy: rgTagDeployedBy
  }
}