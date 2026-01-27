@description('The name of the network security group')
param nsgName string

@description('The location of the network security group')
param location string = resourceGroup().location

@description('Array of security rules')
param securityRules array = []

@description('Tags to apply to the network security group')
param tags object = {}

resource nsg 'Microsoft.Network/networkSecurityGroups@2023-11-01' = {
  name: nsgName
  location: location
  tags: tags
  properties: {
    securityRules: [for rule in securityRules: {
      name: rule.name
      properties: {
        description: contains(rule, 'description') ? rule.description : ''
        protocol: rule.protocol
        sourcePortRange: contains(rule, 'sourcePortRange') ? rule.sourcePortRange : null
        sourcePortRanges: contains(rule, 'sourcePortRanges') ? rule.sourcePortRanges : null
        destinationPortRange: contains(rule, 'destinationPortRange') ? rule.destinationPortRange : null
        destinationPortRanges: contains(rule, 'destinationPortRanges') ? rule.destinationPortRanges : null
        sourceAddressPrefix: contains(rule, 'sourceAddressPrefix') ? rule.sourceAddressPrefix : null
        sourceAddressPrefixes: contains(rule, 'sourceAddressPrefixes') ? rule.sourceAddressPrefixes : null
        destinationAddressPrefix: contains(rule, 'destinationAddressPrefix') ? rule.destinationAddressPrefix : null
        destinationAddressPrefixes: contains(rule, 'destinationAddressPrefixes') ? rule.destinationAddressPrefixes : null
        sourceApplicationSecurityGroups: contains(rule, 'sourceApplicationSecurityGroups') ? rule.sourceApplicationSecurityGroups : null
        destinationApplicationSecurityGroups: contains(rule, 'destinationApplicationSecurityGroups') ? rule.destinationApplicationSecurityGroups : null
        access: rule.access
        priority: rule.priority
        direction: rule.direction
      }
    }]
  }
}

@description('The resource ID of the network security group')
output nsgId string = nsg.id

@description('The name of the network security group')
output nsgName string = nsg.name

@description('Array of security rule names')
output securityRuleNames array = [for (rule, i) in securityRules: nsg.properties.securityRules[i].name]
