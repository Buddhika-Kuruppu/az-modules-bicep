using './main.bicep'

// Secure storage — public network access locked to a specific VNet subnet.
// Replace the subnet resource ID below with the actual ID from your VNet deployment.
// Deploy: az deployment group create --resource-group rg-aue-prod-01 --template-file main.bicep --parameters secure.bicepparam

param location = 'australiaeast'
param environment = 'prod'
param storageAccountName = 'staueprod01'
param skuName = 'Standard_ZRS'
param accessTier = 'Hot'
param networkAcls = {
  bypass: 'AzureServices'
  defaultAction: 'Deny'
  ipRules: []
  virtualNetworkRules: [
    {
      // Obtain this ID from the subnet module output: vnet.outputs.subnetIds[0]
      id: '/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-aue-prod-01/providers/Microsoft.Network/virtualNetworks/vnet-aue-prod-01/subnets/snet-app'
      action: 'Allow'
    }
  ]
}
param publicNetworkAccess = 'Enabled'
param tags = {
  Project: 'MyProject'
  CostCentre: 'IT-001'
  DataClassification: 'Confidential'
}
