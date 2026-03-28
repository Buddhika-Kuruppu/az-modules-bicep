@description('The name of the App Service Environment V3')
param aseName string

@description('The location for the App Service Environment V3')
param location string = resourceGroup().location

@description('Tags to apply to the App Service Environment V3')
param tags object = {}

@description('The resource ID of the subnet delegated to Microsoft.Web/hostingEnvironments (minimum /24)')
param subnetId string

@description('Load balancer mode. 0 = Public (internet-facing), 2 = Internal (ILB)')
@allowed([
  0
  2
])
param internalLoadBalancingMode int = 0

@description('Whether zone redundancy is enabled. Requires at least 9 workers across 3 zones.')
param zoneRedundant bool = false

@description('Custom DNS suffix for the App Service Environment')
param dnsSuffix string = ''

@description('Cluster settings as key-value pairs (e.g., [{name: "DisableTls1.0", value: "1"}])')
param clusterSettings array = []

@description('Whether to allow new private endpoint connections')
param allowNewPrivateEndpointConnections bool = false

@description('Upgrade preference for the ASE. None, Early, Late, or Manual.')
@allowed([
  'None'
  'Early'
  'Late'
  'Manual'
])
param upgradePreference string = 'None'

@description('Whether to enable FTP access')
param ftpEnabled bool = false

@description('Whether to enable remote debugging')
param remoteDebugEnabled bool = false

resource ase 'Microsoft.Web/hostingEnvironments@2023-12-01' = {
  name: aseName
  location: location
  tags: tags
  kind: 'ASEV3'
  properties: {
    virtualNetwork: {
      id: subnetId
    }
    internalLoadBalancingMode: internalLoadBalancingMode == 2 ? 'Web, Publishing' : 'None'
    zoneRedundant: zoneRedundant
    dnsSuffix: !empty(dnsSuffix) ? dnsSuffix : null
    clusterSettings: !empty(clusterSettings) ? clusterSettings : []
    allowNewPrivateEndpointConnections: allowNewPrivateEndpointConnections
    upgradePreference: upgradePreference
    ftpEnabled: ftpEnabled
    remoteDebugEnabled: remoteDebugEnabled
  }
}

@description('The resource ID of the App Service Environment V3')
output aseId string = ase.id

@description('The name of the App Service Environment V3')
output aseName string = ase.name

@description('The location of the App Service Environment V3')
output location string = ase.location

@description('The default DNS suffix of the App Service Environment V3')
output defaultDnsSuffix string = ase.properties.dnsSuffix

@description('The internal load balancing mode of the App Service Environment V3')
output internalLoadBalancingMode string = ase.properties.internalLoadBalancingMode

@description('The provisioning state of the App Service Environment V3')
output provisioningState string = ase.properties.provisioningState
