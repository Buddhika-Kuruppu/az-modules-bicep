targetScope = 'subscription'

@description('The Azure region for resources')
param location string

@description('Environment name')
param environment string

@description('Network Resource Group Name')
param network_rg_name string

module resourceGroup '../../modules/resource-groups/resource-group.bicep' = {
  name: network_rg_name
  params: {
    resourceGroupName: 'rg-${environment}'
    location: location
    tags: {
      Environment: environment
      ManagedBy: 'Bicep'
    }
  }
}

output resourceGroupId string = resourceGroup.outputs.resourceGroupId
output resourceGroupName string = resourceGroup.outputs.resourceGroupName
