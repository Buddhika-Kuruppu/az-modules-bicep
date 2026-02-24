@description('The name of the Storage Account')
param storageAccountName string

@description('The location for the Storage Account')
param location string = resourceGroup().location

@description('Tags to apply to the Storage Account')
param tags object = {}

@description('The SKU name for the Storage Account')
@allowed([
  'Standard_LRS'
  'Standard_GRS'
  'Standard_RAGRS'
  'Standard_ZRS'
  'Premium_LRS'
  'Premium_ZRS'
  'Standard_GZRS'
  'Standard_RAGZRS'
])
param skuName string = 'Standard_LRS'

@description('The kind of Storage Account')
@allowed([
  'Storage'
  'StorageV2'
  'BlobStorage'
  'BlockBlobStorage'
  'FileStorage'
])
param kind string = 'StorageV2'

@description('The access tier for the Storage Account (only applicable to BlobStorage and StorageV2)')
@allowed([
  'Hot'
  'Cool'
])
param accessTier string = 'Hot'

@description('The minimum TLS version required for requests to the Storage Account')
@allowed([
  'TLS1_0'
  'TLS1_1'
  'TLS1_2'
])
param minimumTlsVersion string = 'TLS1_2'

@description('Whether HTTPS traffic only is enforced for the Storage Account')
param supportsHttpsTrafficOnly bool = true

@description('Whether public blob access is allowed')
param allowBlobPublicAccess bool = false

@description('Whether shared key access is allowed')
param allowSharedKeyAccess bool = true

@description('Whether hierarchical namespace (Azure Data Lake Storage Gen2) is enabled')
param isHnsEnabled bool = false

@description('Whether NFSv3 protocol is enabled')
param isNfsV3Enabled bool = false

@description('Whether large file shares are enabled')
@allowed([
  'Disabled'
  'Enabled'
])
param largeFileSharesState string = 'Disabled'

@description('Whether cross-tenant replication is allowed')
param allowCrossTenantReplication bool = false

@description('Network ACL configuration for the Storage Account')
param networkAcls object = {
  bypass: 'AzureServices'
  defaultAction: 'Allow'
  ipRules: []
  virtualNetworkRules: []
}

@description('Whether public network access is enabled')
@allowed([
  'Enabled'
  'Disabled'
])
param publicNetworkAccess string = 'Enabled'

resource storageAccount 'Microsoft.Storage/storageAccounts@2023-05-01' = {
  name: storageAccountName
  location: location
  tags: tags
  sku: {
    name: skuName
  }
  kind: kind
  properties: {
    accessTier: accessTier
    minimumTlsVersion: minimumTlsVersion
    supportsHttpsTrafficOnly: supportsHttpsTrafficOnly
    allowBlobPublicAccess: allowBlobPublicAccess
    allowSharedKeyAccess: allowSharedKeyAccess
    isHnsEnabled: isHnsEnabled
    isNfsV3Enabled: isNfsV3Enabled
    largeFileSharesState: largeFileSharesState
    allowCrossTenantReplication: allowCrossTenantReplication
    networkAcls: networkAcls
    publicNetworkAccess: publicNetworkAccess
  }
}

@description('The resource ID of the Storage Account')
output storageAccountId string = storageAccount.id

@description('The name of the Storage Account')
output storageAccountName string = storageAccount.name

@description('The primary blob endpoint of the Storage Account')
output primaryBlobEndpoint string = storageAccount.properties.primaryEndpoints.blob

@description('The primary file endpoint of the Storage Account')
output primaryFileEndpoint string = storageAccount.properties.primaryEndpoints.file

@description('The primary queue endpoint of the Storage Account')
output primaryQueueEndpoint string = storageAccount.properties.primaryEndpoints.queue

@description('The primary table endpoint of the Storage Account')
output primaryTableEndpoint string = storageAccount.properties.primaryEndpoints.table

@description('The location of the Storage Account')
output location string = storageAccount.location
