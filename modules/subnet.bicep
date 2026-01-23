@description('The name of the subnet')
param subnetName string

@description('The name of the parent virtual network')
param vnetName string

@description('The address prefix for the subnet')
param addressPrefix string

@description('Network Security Group resource ID')
param networkSecurityGroupId string = ''

@description('Route table resource ID')
param routeTableId string = ''

@description('Service endpoints for the subnet')
param serviceEndpoints array = []

@description('Delegations for the subnet')
param delegations array = []

@description('Private endpoint network policies')
@allowed([
  'Disabled'
  'Enabled'
])
param privateEndpointNetworkPolicies string = 'Disabled'

@description('Private link service network policies')
@allowed([
  'Disabled'
  'Enabled'
])
param privateLinkServiceNetworkPolicies string = 'Enabled'

resource vnet 'Microsoft.Network/virtualNetworks@2023-11-01' existing = {
  name: vnetName
}

resource subnet 'Microsoft.Network/virtualNetworks/subnets@2023-11-01' = {
  parent: vnet
  name: subnetName
  properties: {
    addressPrefix: addressPrefix
    networkSecurityGroup: !empty(networkSecurityGroupId) ? {
      id: networkSecurityGroupId
    } : null
    routeTable: !empty(routeTableId) ? {
      id: routeTableId
    } : null
    serviceEndpoints: serviceEndpoints
    delegations: delegations
    privateEndpointNetworkPolicies: privateEndpointNetworkPolicies
    privateLinkServiceNetworkPolicies: privateLinkServiceNetworkPolicies
  }
}

@description('The resource ID of the subnet')
output subnetId string = subnet.id

@description('The name of the subnet')
output subnetName string = subnet.name

@description('The address prefix of the subnet')
output addressPrefix string = subnet.properties.addressPrefix
