// Replace 'mycompanyregistry.azurecr.io' with your Azure Container Registry hostname.

@description('Azure region for resources (defaults to resource group location)')
param location string = resourceGroup().location

@description('Environment label applied as a tag')
param environment string

@description('Name of the Virtual WAN')
param virtualWanName string

@description('The type of the Virtual WAN. Basic supports Site-to-Site VPN only; Standard supports all hub types and higher throughput.')
@allowed([
  'Basic'
  'Standard'
])
param virtualWanType string = 'Standard'

@description('Whether branch-to-branch traffic is allowed (VPN site to VPN site via the WAN)')
param allowBranchToBranchTraffic bool = true

@description('Whether VNet-to-VNet traffic is allowed via the Virtual WAN (only applicable to Basic type; Standard always enables this)')
param allowVnetToVnetTraffic bool = true

@description('Whether VPN encryption is disabled')
param disableVpnEncryption bool = false

@description('Office 365 local breakout category for optimising internet-bound Office 365 traffic')
@allowed([
  'None'
  'Optimize'
  'OptimizeAndAllow'
  'All'
])
param office365LocalBreakoutCategory string = 'None'

@description('Additional tags merged onto all resources')
param tags object = {}

module virtualWan 'br:mycompanyregistry.azurecr.io/bicep/virtual-wans/virtual-wan:v1' = {
  name: 'deploy-${virtualWanName}'
  params: {
    virtualWanName: virtualWanName
    location: location
    virtualWanType: virtualWanType
    allowBranchToBranchTraffic: allowBranchToBranchTraffic
    allowVnetToVnetTraffic: allowVnetToVnetTraffic
    disableVpnEncryption: disableVpnEncryption
    office365LocalBreakoutCategory: office365LocalBreakoutCategory
    tags: union({
      Environment: environment
      ManagedBy: 'Bicep'
    }, tags)
  }
}

output virtualWanId string = virtualWan.outputs.virtualWanId
output virtualWanName string = virtualWan.outputs.virtualWanName
output virtualWanType string = virtualWan.outputs.virtualWanType
output provisioningState string = virtualWan.outputs.provisioningState
