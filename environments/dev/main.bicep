targetScope = 'subscription'

@description('The Azure region for resources')
param location string = 'eastus'

@description('Environment name')
param environment string = 'dev'

module resourceGroup '../../modules/resource-groups/resource-group.bicep' = {
  name: 'rg-deployment-${environment}'
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
