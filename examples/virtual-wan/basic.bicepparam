using './main.bicep'

// Deploy: az deployment group create --resource-group rg-aue-dev-01 --template-file main.bicep --parameters basic.bicepparam

param location = 'australiaeast'
param environment = 'dev'
param virtualWanName = 'vwan-aue-dev-01'
param virtualWanType = 'Basic'
param allowBranchToBranchTraffic = true
param allowVnetToVnetTraffic = false
param disableVpnEncryption = false
param office365LocalBreakoutCategory = 'None'
param tags = {
  Project: 'MyProject'
  CostCentre: 'IT-001'
}
