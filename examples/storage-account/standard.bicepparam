using './main.bicep'

// Standard storage — open public access, suitable for development or non-sensitive data.
// Deploy: az deployment group create --resource-group rg-aue-dev-01 --template-file main.bicep --parameters standard.bicepparam

param location = 'australiaeast'
param environment = 'dev'
param storageAccountName = 'staueddev01'
param skuName = 'Standard_LRS'
param accessTier = 'Hot'
param networkAcls = {
  bypass: 'AzureServices'
  defaultAction: 'Allow'
  ipRules: []
  virtualNetworkRules: []
}
param publicNetworkAccess = 'Enabled'
param tags = {
  Project: 'MyProject'
  CostCentre: 'IT-001'
}
