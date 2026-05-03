// Replace 'mycompanyregistry.azurecr.io' with your Azure Container Registry hostname.
// Publish modules:
//   az bicep publish --file ../../../modules/resource-groups/resource-group.bicep --target br:mycompanyregistry.azurecr.io/bicep/resource-groups/resource-group:v1
//   az bicep publish --file ../../../modules/network-security-groups/network-security-group.bicep --target br:mycompanyregistry.azurecr.io/bicep/network-security-groups/network-security-group:v1
//   az bicep publish --file ../../../modules/virtual-networks/virtual-network.bicep --target br:mycompanyregistry.azurecr.io/bicep/virtual-networks/virtual-network:v1
//   az bicep publish --file ../../../modules/storage-accounts/storage-account.bicep --target br:mycompanyregistry.azurecr.io/bicep/storage-accounts/storage-account:v1

targetScope = 'subscription'

@description('Azure region for all resources')
param location string = 'australiaeast'

@description('Environment label applied as a tag and used in resource naming (e.g. dev, test, prod)')
param environment string

@description('Name of the resource group to create')
param resourceGroupName string

@description('Name of the virtual network')
param vnetName string

@description('Address space for the virtual network in CIDR notation')
param addressPrefix string = '10.0.0.0/16'

@description('Name of the Network Security Group for the app subnet')
param nsgName string

@description('Name of the storage account (3-24 chars, lowercase alphanumeric only)')
@minLength(3)
@maxLength(24)
param storageAccountName string

@description('Additional tags merged onto all resources')
param tags object = {}

var commonTags = union({
  Environment: environment
  ManagedBy: 'Bicep'
}, tags)

module resourceGroup 'br:mycompanyregistry.azurecr.io/bicep/resource-groups/resource-group:v1' = {
  name: 'deploy-${resourceGroupName}'
  params: {
    resourceGroupName: resourceGroupName
    location: location
    tags: commonTags
  }
}

module nsg 'br:mycompanyregistry.azurecr.io/bicep/network-security-groups/network-security-group:v1' = {
  name: 'deploy-${nsgName}'
  scope: resourceGroup(resourceGroup.outputs.resourceGroupName)
  params: {
    nsgName: nsgName
    location: location
    securityRules: [
      {
        name: 'allow-https-inbound'
        protocol: 'Tcp'
        sourcePortRange: '*'
        destinationPortRange: '443'
        sourceAddressPrefix: 'Internet'
        destinationAddressPrefix: '*'
        access: 'Allow'
        priority: 100
        direction: 'Inbound'
      }
      {
        name: 'deny-all-inbound'
        protocol: '*'
        sourcePortRange: '*'
        destinationPortRange: '*'
        sourceAddressPrefix: '*'
        destinationAddressPrefix: '*'
        access: 'Deny'
        priority: 4096
        direction: 'Inbound'
      }
    ]
    tags: commonTags
  }
}

module vnet 'br:mycompanyregistry.azurecr.io/bicep/virtual-networks/virtual-network:v1' = {
  name: 'deploy-${vnetName}'
  scope: resourceGroup(resourceGroup.outputs.resourceGroupName)
  params: {
    vnetName: vnetName
    location: location
    addressPrefix: addressPrefix
    subnets: [
      {
        name: 'snet-app'
        addressPrefix: cidrSubnet(addressPrefix, 24, 1)
        networkSecurityGroupId: nsg.outputs.nsgId
      }
      {
        name: 'snet-data'
        addressPrefix: cidrSubnet(addressPrefix, 24, 2)
        serviceEndpoints: [
          { service: 'Microsoft.Storage' }
        ]
      }
      {
        name: 'snet-mgmt'
        addressPrefix: cidrSubnet(addressPrefix, 24, 3)
      }
    ]
    tags: commonTags
  }
}

module storage 'br:mycompanyregistry.azurecr.io/bicep/storage-accounts/storage-account:v1' = {
  name: 'deploy-${storageAccountName}'
  scope: resourceGroup(resourceGroup.outputs.resourceGroupName)
  params: {
    storageAccountName: storageAccountName
    location: location
    skuName: 'Standard_LRS'
    kind: 'StorageV2'
    accessTier: 'Hot'
    minimumTlsVersion: 'TLS1_2'
    supportsHttpsTrafficOnly: true
    allowBlobPublicAccess: false
    allowSharedKeyAccess: false
    allowCrossTenantReplication: false
    publicNetworkAccess: 'Enabled'
    networkAcls: {
      bypass: 'AzureServices'
      defaultAction: 'Allow'
      ipRules: []
      virtualNetworkRules: []
    }
    tags: commonTags
  }
}

output resourceGroupId string = resourceGroup.outputs.resourceGroupId
output resourceGroupName string = resourceGroup.outputs.resourceGroupName
output nsgId string = nsg.outputs.nsgId
output nsgName string = nsg.outputs.nsgName
output vnetId string = vnet.outputs.vnetId
output vnetName string = vnet.outputs.vnetName
output subnetIds array = vnet.outputs.subnetIds
output subnetNames array = vnet.outputs.subnetNames
output storageAccountId string = storage.outputs.storageAccountId
output storageAccountName string = storage.outputs.storageAccountName
output primaryBlobEndpoint string = storage.outputs.primaryBlobEndpoint
