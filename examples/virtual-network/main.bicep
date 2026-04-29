// Replace 'mycompanyregistry.azurecr.io' with your Azure Container Registry hostname.

@description('Azure region for resources (defaults to resource group location)')
param location string = resourceGroup().location

@description('Environment label applied as a tag')
param environment string

@description('Name of the virtual network')
param vnetName string

@description('Address space for the virtual network in CIDR notation')
param addressPrefix string = '10.0.0.0/16'

@description('Subnet definitions. Each item requires name and addressPrefix; optionally networkSecurityGroupId, serviceEndpoints, delegations.')
param subnets array = []

@description('Custom DNS server IPs. Leave empty to use Azure-provided DNS.')
param dnsServers array = []

@description('Additional tags merged onto all resources')
param tags object = {}

module vnet 'br:mycompanyregistry.azurecr.io/bicep/virtual-networks/virtual-network:v1' = {
  name: 'deploy-${vnetName}'
  params: {
    vnetName: vnetName
    location: location
    addressPrefix: addressPrefix
    subnets: subnets
    dnsServers: dnsServers
    tags: union({
      Environment: environment
      ManagedBy: 'Bicep'
    }, tags)
  }
}

output vnetId string = vnet.outputs.vnetId
output vnetName string = vnet.outputs.vnetName
output addressPrefix string = vnet.outputs.addressPrefix
output subnetIds array = vnet.outputs.subnetIds
output subnetNames array = vnet.outputs.subnetNames
