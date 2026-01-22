@description('The name of the virtual network')
param vnetName string

@description('The location of the virtual network')
param location string = resourceGroup().location

@description('The address prefix for the virtual network')
param addressPrefix string = '10.0.0.0/16'

@description('Array of subnet configurations')
param subnets array = []

@description('Enable DDoS protection')
param enableDdosProtection bool = false

@description('DDoS protection plan ID')
param ddosProtectionPlanId string = ''

@description('DNS servers for the virtual network')
param dnsServers array = []

@description('Tags to apply to the virtual network')
param tags object = {}

resource vnet 'Microsoft.Network/virtualNetworks@2023-11-01' = {
  name: vnetName
  location: location
  tags: tags
  properties: {
    addressSpace: {
      addressPrefixes: [
        addressPrefix
      ]
    }
    dhcpOptions: !empty(dnsServers) ? {
      dnsServers: dnsServers
    } : null
    enableDdosProtection: enableDdosProtection
    ddosProtectionPlan: enableDdosProtection && !empty(ddosProtectionPlanId) ? {
      id: ddosProtectionPlanId
    } : null
    subnets: [for subnet in subnets: {
      name: subnet.name
      properties: {
        addressPrefix: subnet.addressPrefix
        networkSecurityGroup: contains(subnet, 'networkSecurityGroupId') && !empty(subnet.networkSecurityGroupId) ? {
          id: subnet.networkSecurityGroupId
        } : null
        routeTable: contains(subnet, 'routeTableId') && !empty(subnet.routeTableId) ? {
          id: subnet.routeTableId
        } : null
        serviceEndpoints: contains(subnet, 'serviceEndpoints') ? subnet.serviceEndpoints : []
        delegations: contains(subnet, 'delegations') ? subnet.delegations : []
        privateEndpointNetworkPolicies: contains(subnet, 'privateEndpointNetworkPolicies') ? subnet.privateEndpointNetworkPolicies : 'Disabled'
        privateLinkServiceNetworkPolicies: contains(subnet, 'privateLinkServiceNetworkPolicies') ? subnet.privateLinkServiceNetworkPolicies : 'Enabled'
      }
    }]
  }
}

@description('The resource ID of the virtual network')
output vnetId string = vnet.id

@description('The name of the virtual network')
output vnetName string = vnet.name

@description('The address prefix of the virtual network')
output addressPrefix string = vnet.properties.addressSpace.addressPrefixes[0]

@description('Array of subnet resource IDs')
output subnetIds array = [for (subnet, i) in subnets: vnet.properties.subnets[i].id]

@description('Array of subnet names')
output subnetNames array = [for (subnet, i) in subnets: vnet.properties.subnets[i].name]
