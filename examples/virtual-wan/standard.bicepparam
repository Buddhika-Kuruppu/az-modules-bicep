using './main.bicep'

// Deploy: az deployment group create --resource-group rg-aue-prod-01 --template-file main.bicep --parameters standard.bicepparam

param location = 'australiaeast'
param environment = 'prod'
param virtualWanName = 'vwan-aue-prod-01'
param virtualWanType = 'Standard'
param allowBranchToBranchTraffic = true
param allowVnetToVnetTraffic = true
param disableVpnEncryption = false
param office365LocalBreakoutCategory = 'OptimizeAndAllow'
param tags = {
  Project: 'MyProject'
  CostCentre: 'IT-001'
}
