@description('The name of the API Management service')
param apimName string

@description('The location for the API Management service')
param location string = resourceGroup().location

@description('Tags to apply to the API Management service')
param tags object = {}

@description('The email address of the publisher')
param publisherEmail string

@description('The name of the publisher organisation')
param publisherName string

@description('The SKU name for the API Management service')
@allowed([
  'Consumption'
  'Developer'
  'Basic'
  'BasicV2'
  'Standard'
  'StandardV2'
  'Premium'
])
param skuName string = 'Developer'

@description('The number of deployed units. Use 0 for Consumption.')
@minValue(0)
@maxValue(31)
param skuCapacity int = 1

@description('The type of VNet integration. None = no VNet, External = internet-facing via VNet, Internal = private only. VNet integration requires Developer, Premium, BasicV2, or StandardV2.')
@allowed([
  'None'
  'External'
  'Internal'
])
param virtualNetworkType string = 'None'

@description('The resource ID of the subnet for VNet integration (required when virtualNetworkType is External or Internal)')
param subnetId string = ''

@description('Whether public network access is enabled')
@allowed([
  'Enabled'
  'Disabled'
])
param publicNetworkAccess string = 'Enabled'

@description('Whether client certificate authentication is enabled on the gateway (Consumption tier only)')
param enableClientCertificate bool = false

@description('The email address from which notification emails are sent')
param notificationSenderEmail string = 'apimgmt-noreply@mail.windowsazure.com'

@description('Custom properties for the service (e.g., cipher/protocol overrides). See Azure docs for supported keys.')
param customProperties object = {}

@description('Availability zones for zone-redundant deployment (Premium tier only, e.g. ["1","2","3"])')
param zones array = []

resource apim 'Microsoft.ApiManagement/service@2023-09-01-preview' = {
  name: apimName
  location: location
  tags: tags
  sku: {
    name: skuName
    capacity: skuCapacity
  }
  zones: !empty(zones) ? zones : null
  properties: {
    publisherEmail: publisherEmail
    publisherName: publisherName
    notificationSenderEmail: notificationSenderEmail
    virtualNetworkType: virtualNetworkType
    virtualNetworkConfiguration: !empty(subnetId) ? { subnetResourceId: subnetId } : null
    publicNetworkAccess: publicNetworkAccess
    enableClientCertificate: enableClientCertificate
    customProperties: !empty(customProperties) ? customProperties : null
  }
}

@description('The resource ID of the API Management service')
output apimId string = apim.id

@description('The name of the API Management service')
output apimName string = apim.name

@description('The gateway URL of the API Management service')
output gatewayUrl string = apim.properties.gatewayUrl

@description('The management API URL of the API Management service')
output managementApiUrl string = apim.properties.managementApiUrl

@description('The developer portal URL of the API Management service')
output developerPortalUrl string = apim.properties.developerPortalUrl

@description('The public IP addresses of the API Management service')
output publicIpAddresses array = apim.properties.publicIPAddresses

@description('The private IP addresses of the API Management service (populated when VNet integrated)')
output privateIpAddresses array = apim.properties.privateIPAddresses

@description('The location of the API Management service')
output location string = apim.location
