// Replace 'mycompanyregistry.azurecr.io' with your Azure Container Registry hostname.

@description('Azure region for resources (defaults to resource group location)')
param location string = resourceGroup().location

@description('Environment label applied as a tag')
param environment string

@description('Name of the storage account (3-24 chars, lowercase alphanumeric only)')
@minLength(3)
@maxLength(24)
param storageAccountName string

@description('Redundancy SKU')
@allowed(['Standard_LRS', 'Standard_GRS', 'Standard_RAGRS', 'Standard_ZRS', 'Standard_GZRS', 'Standard_RAGZRS'])
param skuName string = 'Standard_ZRS'

@description('Access tier for blob and StorageV2 accounts')
@allowed(['Hot', 'Cool'])
param accessTier string = 'Hot'

@description('Network ACL configuration. Set defaultAction to Deny and add virtualNetworkRules to restrict access to specific subnets.')
param networkAcls object = {
  bypass: 'AzureServices'
  defaultAction: 'Allow'
  ipRules: []
  virtualNetworkRules: []
}

@description('Whether public network access is enabled. Set to Disabled to block all public traffic.')
@allowed(['Enabled', 'Disabled'])
param publicNetworkAccess string = 'Enabled'

@description('Additional tags merged onto all resources')
param tags object = {}

module storage 'br:mycompanyregistry.azurecr.io/bicep/storage-accounts/storage-account:v1' = {
  name: 'deploy-${storageAccountName}'
  params: {
    storageAccountName: storageAccountName
    location: location
    skuName: skuName
    kind: 'StorageV2'
    accessTier: accessTier
    minimumTlsVersion: 'TLS1_2'
    supportsHttpsTrafficOnly: true
    allowBlobPublicAccess: false
    allowSharedKeyAccess: false
    allowCrossTenantReplication: false
    publicNetworkAccess: publicNetworkAccess
    networkAcls: networkAcls
    tags: union({
      Environment: environment
      ManagedBy: 'Bicep'
    }, tags)
  }
}

output storageAccountId string = storage.outputs.storageAccountId
output storageAccountName string = storage.outputs.storageAccountName
output primaryBlobEndpoint string = storage.outputs.primaryBlobEndpoint
output primaryFileEndpoint string = storage.outputs.primaryFileEndpoint
output primaryQueueEndpoint string = storage.outputs.primaryQueueEndpoint
output primaryTableEndpoint string = storage.outputs.primaryTableEndpoint
