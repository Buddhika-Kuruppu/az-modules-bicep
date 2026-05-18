@description('The name of the Virtual WAN')
param virtualWanName string

@description('The location for the Virtual WAN')
param location string

@description('Tags to apply to the Virtual WAN')
param tags object

@description('The type of the Virtual WAN. Basic supports Site-to-Site VPN only; Standard supports all hub types and higher throughput.')
@allowed([
  'Basic'
  'Standard'
])
param virtualWanType string

@description('Whether branch-to-branch traffic is allowed (VPN site to VPN site via the WAN)')
param allowBranchToBranchTraffic bool

@description('Whether VNet-to-VNet traffic is allowed via the Virtual WAN (only applicable to Basic type; Standard always enables this)')
param allowVnetToVnetTraffic bool

@description('Whether VPN encryption is disabled')
param disableVpnEncryption bool

resource virtualWan 'Microsoft.Network/virtualWans@2023-11-01' = {
  name: virtualWanName
  location: location
  tags: tags
  properties: {
    type: virtualWanType
    allowBranchToBranchTraffic: allowBranchToBranchTraffic
    allowVnetToVnetTraffic: allowVnetToVnetTraffic
    disableVpnEncryption: disableVpnEncryption
  }
}

@description('The resource ID of the Virtual WAN')
output virtualWanId string = virtualWan.id

@description('The name of the Virtual WAN')
output virtualWanName string = virtualWan.name

@description('The type of the Virtual WAN')
output virtualWanType string = virtualWan.properties.type

@description('The provisioning state of the Virtual WAN')
output provisioningState string = virtualWan.properties.provisioningState

@description('The location of the Virtual WAN')
output location string = virtualWan.location
