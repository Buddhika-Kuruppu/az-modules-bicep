// Replace 'mycompanyregistry.azurecr.io' with your Azure Container Registry hostname.

@description('Azure region for resources (defaults to resource group location)')
param location string = resourceGroup().location

@description('Environment label applied as a tag')
param environment string

@description('Name of the API Management service (globally unique, 1-50 alphanumeric or hyphens)')
@minLength(1)
@maxLength(50)
param apimName string

@description('Email address of the publisher (used for system notifications)')
param publisherEmail string

@description('Name of the publisher organisation')
param publisherName string

@description('SKU name for the API Management service')
@allowed(['Consumption', 'Developer', 'Basic', 'BasicV2', 'Standard', 'StandardV2', 'Premium'])
param skuName string = 'Developer'

@description('Number of deployed units (0 for Consumption)')
@minValue(0)
@maxValue(31)
param skuCapacity int = 1

@description('VNet integration type')
@allowed(['None', 'External', 'Internal'])
param virtualNetworkType string = 'None'

@description('Subnet resource ID for VNet integration (required when virtualNetworkType is not None)')
param subnetId string = ''

@description('Whether public network access is enabled')
@allowed(['Enabled', 'Disabled'])
param publicNetworkAccess string = 'Enabled'

@description('Additional tags merged onto all resources')
param tags object = {}

module apim 'br:mycompanyregistry.azurecr.io/bicep/api-management/api-management:v1' = {
  name: 'deploy-${apimName}'
  params: {
    apimName: apimName
    location: location
    publisherEmail: publisherEmail
    publisherName: publisherName
    skuName: skuName
    skuCapacity: skuCapacity
    virtualNetworkType: virtualNetworkType
    subnetId: subnetId
    publicNetworkAccess: publicNetworkAccess
    tags: union({
      Environment: environment
      ManagedBy: 'Bicep'
    }, tags)
  }
}

output apimId string = apim.outputs.apimId
output apimName string = apim.outputs.apimName
output gatewayUrl string = apim.outputs.gatewayUrl
output managementApiUrl string = apim.outputs.managementApiUrl
output developerPortalUrl string = apim.outputs.developerPortalUrl
