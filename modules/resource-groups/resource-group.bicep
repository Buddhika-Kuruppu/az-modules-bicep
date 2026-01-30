@description('The name of the resource group')
param resourceGroupName string

@description('The location of the resource group')
param location string

@description('Tags to apply to the resource group')
param tags object = {}

targetScope = 'subscription'

resource rg 'Microsoft.Resources/resourceGroups@2024-03-01' = {
  name: resourceGroupName
  location: location
  tags: tags
}

@description('The resource ID of the resource group')
output resourceGroupId string = rg.id

@description('The name of the resource group')
output resourceGroupName string = rg.name

@description('The location of the resource group')
output location string = rg.location
