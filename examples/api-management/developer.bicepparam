using './main.bicep'

// Developer tier — single unit, full feature set including developer portal and VNet integration.
// Not for production; use Standard or Premium for production workloads.
// Replace the subnet resource ID below with the actual ID from your VNet deployment.
// Deploy: az deployment group create --resource-group rg-aue-dev-01 --template-file main.bicep --parameters developer.bicepparam

param location = 'australiaeast'
param environment = 'dev'
param apimName = 'apim-aue-dev-01'
param publisherEmail = 'admin@example.com'
param publisherName = 'My Organisation'
param skuName = 'Developer'
param skuCapacity = 1
param virtualNetworkType = 'Internal'
// Obtain this ID from the subnet module output: subnet.outputs.subnetId
param subnetId = '/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-aue-dev-01/providers/Microsoft.Network/virtualNetworks/vnet-aue-dev-01/subnets/snet-apim'
param publicNetworkAccess = 'Disabled'
param tags = {
  Project: 'MyProject'
  CostCentre: 'IT-001'
}
