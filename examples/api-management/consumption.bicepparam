using './main.bicep'

// Consumption tier — serverless, pay-per-call, no developer portal, no VNet integration.
// Suitable for dev/test or low-volume workloads. Capacity must be 0.
// Deploy: az deployment group create --resource-group rg-aue-dev-01 --template-file main.bicep --parameters consumption.bicepparam

param location = 'australiaeast'
param environment = 'dev'
param apimName = 'apim-aue-dev-01'
param publisherEmail = 'admin@example.com'
param publisherName = 'My Organisation'
param skuName = 'Consumption'
param skuCapacity = 0
param virtualNetworkType = 'None'
param subnetId = ''
param publicNetworkAccess = 'Enabled'
param tags = {
  Project: 'MyProject'
  CostCentre: 'IT-001'
}
