using './main.bicep'

// Deploy: az deployment sub create --location australiaeast --template-file main.bicep --parameters main.bicepparam

param location = 'australiaeast'
param environment = 'dev'
param resourceGroupName = 'rg-aue-dev-01'
param tags = {
  Project: 'MyProject'
  CostCentre: 'IT-001'
}
