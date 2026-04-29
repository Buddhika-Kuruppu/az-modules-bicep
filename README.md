# az-modules-bicep

Reusable Azure Bicep modules for infrastructure-as-code deployments. Each module is self-contained and can be consumed independently or composed together.

## Repository Structure

```
modules/
├── app-service-environments/ # App Service Environment V3 (isolated hosting)
├── app-service-plans/        # App Service Plan (server farm)
├── network-security-groups/  # Network Security Group with security rules
├── resource-groups/          # Resource Group (subscription scope)
├── storage-accounts/         # Storage Account
├── subnets/                  # Subnet within an existing VNet
├── virtual-network-peerings/ # VNet-to-VNet peering
└── virtual-networks/         # Virtual Network with optional subnets

environments/
└── dev/                      # Dev environment deployment entry point

examples/
├── resource-group/           # Create a resource group
├── virtual-network/          # VNet with subnets
├── network-security-group/   # NSG with security rules
├── storage-account/          # Storage account (standard and secure variants)
├── app-service-plan/         # App Service Plan (Linux and Windows variants)
├── app-service-environment/  # ASEv3 with dedicated networking
└── hub-spoke-network/        # Full hub-spoke topology with peering
```

---

## Using modules from a registry

Modules are designed to be published to an Azure Container Registry (ACR) and consumed remotely. Replace `mycompanyregistry.azurecr.io` throughout the examples with your own registry hostname.

**Publish a module to ACR:**
```bash
az bicep publish \
  --file modules/resource-groups/resource-group.bicep \
  --target br:mycompanyregistry.azurecr.io/bicep/resource-groups/resource-group:v1
```

**Reference the published module in your Bicep template:**
```bicep
module rg 'br:mycompanyregistry.azurecr.io/bicep/resource-groups/resource-group:v1' = {
  name: 'deploy-rg'
  params: {
    resourceGroupName: 'rg-aue-dev-01'
    location: 'australiaeast'
  }
}
```

See the [`examples/`](examples/) directory for ready-to-use deployments covering each module.

---

## Modules

### Resource Group

**Path:** `modules/resource-groups/resource-group.bicep`
**Scope:** `subscription`

Creates an Azure Resource Group.

| Parameter | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| `resourceGroupName` | string | Yes | — | Name of the resource group |
| `location` | string | Yes | — | Azure region |
| `tags` | object | No | `{}` | Tags to apply |

| Output | Type | Description |
|--------|------|-------------|
| `resourceGroupId` | string | Resource ID of the resource group |
| `resourceGroupName` | string | Name of the resource group |
| `location` | string | Location of the resource group |

**Usage:**
```bicep
targetScope = 'subscription'

module rg 'modules/resource-groups/resource-group.bicep' = {
  name: 'deploy-rg'
  params: {
    resourceGroupName: 'rg-aue-network-01'
    location: 'australiaeast'
    tags: {
      Environment: 'dev'
      ManagedBy: 'Bicep'
    }
  }
}
```

---

### Virtual Network

**Path:** `modules/virtual-networks/virtual-network.bicep`
**Scope:** `resourceGroup`

Creates a Virtual Network with optional inline subnet definitions, DNS servers, and DDoS protection.

| Parameter | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| `vnetName` | string | Yes | — | Name of the VNet |
| `location` | string | No | `resourceGroup().location` | Azure region |
| `addressPrefix` | string | No | `10.0.0.0/16` | Address space CIDR |
| `subnets` | array | No | `[]` | Inline subnet configurations |
| `dnsServers` | array | No | `[]` | Custom DNS server IPs |
| `enableDdosProtection` | bool | No | `false` | Enable DDoS Standard protection |
| `ddosProtectionPlanId` | string | No | `''` | DDoS protection plan resource ID |
| `tags` | object | No | `{}` | Tags to apply |

| Output | Type | Description |
|--------|------|-------------|
| `vnetId` | string | Resource ID of the VNet |
| `vnetName` | string | Name of the VNet |
| `addressPrefix` | string | Primary address prefix |
| `subnetIds` | array | Array of subnet resource IDs |
| `subnetNames` | array | Array of subnet names |

**Usage:**
```bicep
module vnet 'modules/virtual-networks/virtual-network.bicep' = {
  name: 'deploy-vnet'
  params: {
    vnetName: 'vnet-aue-dev-01'
    addressPrefix: '10.0.0.0/16'
    subnets: [
      {
        name: 'snet-app'
        addressPrefix: '10.0.1.0/24'
        networkSecurityGroupId: nsg.outputs.nsgId
      }
    ]
    tags: {
      Environment: 'dev'
    }
  }
}
```

---

### Subnet

**Path:** `modules/subnets/subnet.bicep`
**Scope:** `resourceGroup`

Creates a Subnet within an existing Virtual Network. Use this module when managing subnets independently of the VNet.

| Parameter | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| `subnetName` | string | Yes | — | Name of the subnet |
| `vnetName` | string | Yes | — | Name of the parent VNet |
| `addressPrefix` | string | Yes | — | Subnet CIDR |
| `networkSecurityGroupId` | string | No | `''` | NSG resource ID to associate |
| `routeTableId` | string | No | `''` | Route table resource ID |
| `serviceEndpoints` | array | No | `[]` | Service endpoints (e.g., `Microsoft.Storage`) |
| `delegations` | array | No | `[]` | Subnet delegations |
| `privateEndpointNetworkPolicies` | string | No | `Disabled` | `Enabled` or `Disabled` |
| `privateLinkServiceNetworkPolicies` | string | No | `Enabled` | `Enabled` or `Disabled` |

| Output | Type | Description |
|--------|------|-------------|
| `subnetId` | string | Resource ID of the subnet |
| `subnetName` | string | Name of the subnet |
| `addressPrefix` | string | Address prefix of the subnet |

**Usage:**
```bicep
module subnet 'modules/subnets/subnet.bicep' = {
  name: 'deploy-subnet-app'
  params: {
    subnetName: 'snet-app'
    vnetName: 'vnet-aue-dev-01'
    addressPrefix: '10.0.1.0/24'
    networkSecurityGroupId: nsg.outputs.nsgId
  }
}
```

---

### Network Security Group

**Path:** `modules/network-security-groups/network-security-group.bicep`
**Scope:** `resourceGroup`

Creates a Network Security Group with optional security rules.

| Parameter | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| `nsgName` | string | Yes | — | Name of the NSG |
| `location` | string | No | `resourceGroup().location` | Azure region |
| `securityRules` | array | No | `[]` | Array of security rule objects |
| `tags` | object | No | `{}` | Tags to apply |

Each security rule object supports: `name`, `protocol`, `sourcePortRange`/`sourcePortRanges`, `destinationPortRange`/`destinationPortRanges`, `sourceAddressPrefix`/`sourceAddressPrefixes`, `destinationAddressPrefix`/`destinationAddressPrefixes`, `access`, `priority`, `direction`, `description`, `sourceApplicationSecurityGroups`, `destinationApplicationSecurityGroups`.

| Output | Type | Description |
|--------|------|-------------|
| `nsgId` | string | Resource ID of the NSG |
| `nsgName` | string | Name of the NSG |
| `securityRuleNames` | array | Array of security rule names |

**Usage:**
```bicep
module nsg 'modules/network-security-groups/network-security-group.bicep' = {
  name: 'deploy-nsg-app'
  params: {
    nsgName: 'nsg-aue-app-01'
    securityRules: [
      {
        name: 'allow-https-inbound'
        protocol: 'Tcp'
        sourcePortRange: '*'
        destinationPortRange: '443'
        sourceAddressPrefix: 'Internet'
        destinationAddressPrefix: '*'
        access: 'Allow'
        priority: 100
        direction: 'Inbound'
      }
    ]
    tags: {
      Environment: 'dev'
    }
  }
}
```

---

### Virtual Network Peering

**Path:** `modules/virtual-network-peerings/virtual-network-peering.bicep`
**Scope:** `resourceGroup`

Creates a VNet peering from a local VNet to a remote VNet. For bi-directional peering, deploy this module twice (once per direction).

| Parameter | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| `peeringName` | string | Yes | — | Name of the peering |
| `localVnetId` | string | Yes | — | Resource ID of the local VNet |
| `remoteVnetId` | string | Yes | — | Resource ID of the remote VNet |
| `allowVirtualNetworkAccess` | bool | No | `true` | Allow traffic between peered VNets |
| `allowForwardedTraffic` | bool | No | `false` | Allow forwarded traffic from remote |
| `allowGatewayTransit` | bool | No | `false` | Allow gateway transit |
| `useRemoteGateways` | bool | No | `false` | Use remote VNet gateways |
| `syncRemoteAddressSpace` | bool | No | `true` | Sync remote address space on update |

| Output | Type | Description |
|--------|------|-------------|
| `peeringId` | string | Resource ID of the peering |
| `peeringName` | string | Name of the peering |
| `peeringState` | string | Current peering state |

**Usage:**
```bicep
module peering 'modules/virtual-network-peerings/virtual-network-peering.bicep' = {
  name: 'deploy-peering-hub-to-spoke'
  params: {
    peeringName: 'peer-hub-to-spoke'
    localVnetId: hubVnet.outputs.vnetId
    remoteVnetId: spokeVnet.outputs.vnetId
    allowForwardedTraffic: true
    allowGatewayTransit: true
  }
}
```

---

### App Service Plan

**Path:** `modules/app-service-plans/app-service-plan.bicep`
**Scope:** `resourceGroup`

Creates an App Service Plan (server farm) for hosting web apps, APIs, or function apps.

| Parameter | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| `appServicePlanName` | string | Yes | — | Name of the App Service Plan |
| `location` | string | No | `resourceGroup().location` | Azure region |
| `skuName` | string | No | `F1` | SKU name (e.g., `F1`, `B1`, `S1`, `P1v3`) |
| `skuTier` | string | No | `Free` | SKU tier: `Free`, `Basic`, `Standard`, `Premium`, `PremiumV2`, `PremiumV3`, `Isolated`, `IsolatedV2` |
| `skuCapacity` | int | No | `1` | Number of workers |
| `kind` | string | No | `app` | Plan kind: `app`, `linux`, `windows`, `functionapp`, `elastic` |
| `reserved` | bool | No | `false` | Must be `true` for Linux plans |
| `perSiteScaling` | bool | No | `false` | Enable per-app scaling |
| `zoneRedundant` | bool | No | `false` | Enable availability zone redundancy |
| `tags` | object | No | `{}` | Tags to apply |

| Output | Type | Description |
|--------|------|-------------|
| `appServicePlanId` | string | Resource ID of the App Service Plan |
| `appServicePlanName` | string | Name of the App Service Plan |
| `skuName` | string | SKU name of the plan |
| `location` | string | Location of the plan |

**Usage:**
```bicep
module asp 'modules/app-service-plans/app-service-plan.bicep' = {
  name: 'deploy-asp'
  params: {
    appServicePlanName: 'asp-aue-dev-01'
    skuName: 'B1'
    skuTier: 'Basic'
    kind: 'linux'
    reserved: true
    tags: {
      Environment: 'dev'
    }
  }
}
```

---

### Storage Account

**Path:** `modules/storage-accounts/storage-account.bicep`
**Scope:** `resourceGroup`

Creates a Storage Account with configurable redundancy, access tier, security settings, and network ACLs.

| Parameter | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| `storageAccountName` | string | Yes | — | Name of the Storage Account (3–24 chars, lowercase alphanumeric) |
| `location` | string | No | `resourceGroup().location` | Azure region |
| `skuName` | string | No | `Standard_LRS` | SKU: `Standard_LRS`, `Standard_GRS`, `Standard_RAGRS`, `Standard_ZRS`, `Premium_LRS`, `Premium_ZRS`, `Standard_GZRS`, `Standard_RAGZRS` |
| `kind` | string | No | `StorageV2` | Kind: `Storage`, `StorageV2`, `BlobStorage`, `BlockBlobStorage`, `FileStorage` |
| `accessTier` | string | No | `Hot` | `Hot` or `Cool` (applies to BlobStorage and StorageV2) |
| `minimumTlsVersion` | string | No | `TLS1_2` | Minimum TLS version: `TLS1_0`, `TLS1_1`, `TLS1_2` |
| `supportsHttpsTrafficOnly` | bool | No | `true` | Enforce HTTPS-only traffic |
| `allowBlobPublicAccess` | bool | No | `false` | Allow anonymous public blob access |
| `allowSharedKeyAccess` | bool | No | `true` | Allow access via shared key |
| `isHnsEnabled` | bool | No | `false` | Enable hierarchical namespace (ADLS Gen2) |
| `isNfsV3Enabled` | bool | No | `false` | Enable NFSv3 protocol |
| `largeFileSharesState` | string | No | `Disabled` | `Enabled` or `Disabled` |
| `allowCrossTenantReplication` | bool | No | `false` | Allow cross-tenant object replication |
| `networkAcls` | object | No | See below | Network ACL configuration |
| `publicNetworkAccess` | string | No | `Enabled` | `Enabled` or `Disabled` |
| `tags` | object | No | `{}` | Tags to apply |

Default `networkAcls`:
```json
{
  "bypass": "AzureServices",
  "defaultAction": "Allow",
  "ipRules": [],
  "virtualNetworkRules": []
}
```

| Output | Type | Description |
|--------|------|-------------|
| `storageAccountId` | string | Resource ID of the Storage Account |
| `storageAccountName` | string | Name of the Storage Account |
| `primaryBlobEndpoint` | string | Primary Blob service endpoint |
| `primaryFileEndpoint` | string | Primary File service endpoint |
| `primaryQueueEndpoint` | string | Primary Queue service endpoint |
| `primaryTableEndpoint` | string | Primary Table service endpoint |
| `location` | string | Location of the Storage Account |

**Usage:**
```bicep
module storage 'modules/storage-accounts/storage-account.bicep' = {
  name: 'deploy-storage'
  params: {
    storageAccountName: 'staueddev01'
    skuName: 'Standard_ZRS'
    kind: 'StorageV2'
    accessTier: 'Hot'
    allowBlobPublicAccess: false
    publicNetworkAccess: 'Disabled'
    networkAcls: {
      bypass: 'AzureServices'
      defaultAction: 'Deny'
      ipRules: []
      virtualNetworkRules: []
    }
    tags: {
      Environment: 'dev'
    }
  }
}
```

---

## Environments

The `environments/` directory contains environment-specific entry points that compose the modules above.

### Dev (`environments/dev/`)

Deploys a resource group for the dev environment.

```bash
# Deploy using Azure CLI
az deployment sub create \
  --location australiaeast \
  --template-file environments/dev/main.bicep \
  --parameters environments/dev/main.bicepparam
```
