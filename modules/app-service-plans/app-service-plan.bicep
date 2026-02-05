@description('The name of the App Service Plan')
param appServicePlanName string

@description('The location for the App Service Plan')
param location string = resourceGroup().location

@description('Tags to apply to the App Service Plan')
param tags object = {}

@description('The SKU name for the App Service Plan (e.g., F1, B1, S1, P1v2, P1v3)')
param skuName string = 'F1'

@description('The SKU tier for the App Service Plan (e.g., Free, Basic, Standard, Premium, PremiumV2, PremiumV3)')
@allowed([
  'Free'
  'Shared'
  'Basic'
  'Standard'
  'Premium'
  'PremiumV2'
  'PremiumV3'
  'Isolated'
  'IsolatedV2'
])
param skuTier string = 'Free'

@description('The number of workers for the App Service Plan')
param skuCapacity int = 1

@description('The kind of App Service Plan (e.g., app, linux, windows, functionapp, elastic)')
@allowed([
  'app'
  'linux'
  'windows'
  'functionapp'
  'elastic'
])
param kind string = 'app'

@description('Whether the App Service Plan is reserved (required for Linux)')
param reserved bool = false

@description('Whether per-site scaling is enabled')
param perSiteScaling bool = false

@description('Whether zone redundancy is enabled')
param zoneRedundant bool = false

resource appServicePlan 'Microsoft.Web/serverfarms@2023-12-01' = {
  name: appServicePlanName
  location: location
  tags: tags
  kind: kind
  sku: {
    name: skuName
    tier: skuTier
    capacity: skuCapacity
  }
  properties: {
    reserved: reserved
    perSiteScaling: perSiteScaling
    zoneRedundant: zoneRedundant
  }
}

@description('The resource ID of the App Service Plan')
output appServicePlanId string = appServicePlan.id

@description('The name of the App Service Plan')
output appServicePlanName string = appServicePlan.name

@description('The SKU name of the App Service Plan')
output skuName string = appServicePlan.sku.name

@description('The location of the App Service Plan')
output location string = appServicePlan.location
