using './main.bicep'

// Deploy: az deployment sub create --location australiaeast --template-file main.bicep --parameters main.bicepparam

param location = 'australiaeast'
param environment = 'dev'
param resourceGroupName = 'rg-aue-dev-01'
param vnetName = 'vnet-aue-dev-01'
param addressPrefix = '10.0.0.0/16'
param nsgName = 'nsg-aue-dev-app-01'
param storageAccountName = 'staueddev01'
param tags = {
  Project: 'MyProject'
  CostCentre: 'IT-001'
}
