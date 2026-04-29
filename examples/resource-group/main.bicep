// Replace 'mycompanyregistry.azurecr.io' with your Azure Container Registry hostname.
// Publish: az bicep publish --file ../../modules/resource-groups/resource-group.bicep --target br:mycompanyregistry.azurecr.io/bicep/resource-groups/resource-group:v1

targetScope = 'subscription'

@description('Azure region to deploy the resource group into')
param location string

@description('Environment label applied as a tag (e.g. dev, test, prod)')
param environment string

@description('Name of the resource group to create')
param resourceGroupName string

@description('Additional tags merged onto all resources')
param tags object = {}

module resourceGroup 'br:mycompanyregistry.azurecr.io/bicep/resource-groups/resource-group:v1' = {
  name: 'deploy-${resourceGroupName}'
  params: {
    resourceGroupName: resourceGroupName
    location: location
    tags: union({
      Environment: environment
      ManagedBy: 'Bicep'
    }, tags)
  }
}

output resourceGroupId string = resourceGroup.outputs.resourceGroupId
output resourceGroupName string = resourceGroup.outputs.resourceGroupName
output location string = resourceGroup.outputs.location
