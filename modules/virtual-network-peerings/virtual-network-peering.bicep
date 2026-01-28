@description('The name of the virtual network peering')
param peeringName string

@description('The resource ID of the local virtual network')
param localVnetId string

@description('The resource ID of the remote virtual network')
param remoteVnetId string

@description('Allow virtual network access from local to remote')
param allowVirtualNetworkAccess bool = true

@description('Allow forwarded traffic from remote network')
param allowForwardedTraffic bool = false

@description('Allow gateway transit')
param allowGatewayTransit bool = false

@description('Use remote gateways')
param useRemoteGateways bool = false

@description('Sync remote address space')
param syncRemoteAddressSpace bool = true

resource localVnet 'Microsoft.Network/virtualNetworks@2023-11-01' existing = {
  name: split(localVnetId, '/')[8]
}

resource peering 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2023-11-01' = {
  parent: localVnet
  name: peeringName
  properties: {
    allowVirtualNetworkAccess: allowVirtualNetworkAccess
    allowForwardedTraffic: allowForwardedTraffic
    allowGatewayTransit: allowGatewayTransit
    useRemoteGateways: useRemoteGateways
    remoteVirtualNetwork: {
      id: remoteVnetId
    }
    syncRemoteAddressSpace: syncRemoteAddressSpace ? 'true' : 'false'
  }
}

@description('The resource ID of the virtual network peering')
output peeringId string = peering.id

@description('The name of the virtual network peering')
output peeringName string = peering.name

@description('The peering state')
output peeringState string = peering.properties.peeringState
