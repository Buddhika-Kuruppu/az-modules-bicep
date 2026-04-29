using './main.bicep'

// Deploy: az deployment group create --resource-group rg-aue-dev-01 --template-file main.bicep --parameters main.bicepparam

param location = 'australiaeast'
param environment = 'dev'
param vnetName = 'vnet-aue-dev-01'
param addressPrefix = '10.0.0.0/16'
param subnets = [
  {
    name: 'snet-app'
    addressPrefix: '10.0.1.0/24'
  }
  {
    name: 'snet-data'
    addressPrefix: '10.0.2.0/24'
    serviceEndpoints: [
      { service: 'Microsoft.Storage' }
      { service: 'Microsoft.Sql' }
    ]
  }
  {
    name: 'snet-mgmt'
    addressPrefix: '10.0.3.0/24'
  }
]
param tags = {
  Project: 'MyProject'
  CostCentre: 'IT-001'
}
